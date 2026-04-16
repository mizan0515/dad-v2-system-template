# DAD 상태와 세션 라이프사이클

공유 상태, 세션 디렉터리, 라이프사이클 규칙은 이 파일을 기준으로 본다.

## 공유 상태

상태 파일: `Document/dialogue/state.json`

세션 디렉터리: `Document/dialogue/sessions/{session-id}/`

Backlog 파일: `Document/dialogue/backlog.json`

루트 `state.json`은 현재 활성 세션만 추적한다. 새 세션이 생성되면 루트 state는 덮어쓰고, 이전 세션 상태는 `sessions/{session-id}/state.json`에 남긴다.

## 운영 선호 규칙

- outcome-scoped 세션을 우선한다. 각 세션은 구체적 artifact, 검증된 결정, 또는 명시적 risk disposition을 목표로 해야 한다.
- backlog는 execution truth가 아니라 admission metadata다. current session continuation은 여전히 `handoff.next_task`에 둔다.
- DAD 시스템 자체를 수리하는 경우가 아니면 wording correction, state/summary sync, closure seal, validator-noise cleanup만을 위한 새 세션을 열지 않는다.
- 목표, 검증 표면, 작업 소유 범위가 크게 바뀌면 하나의 긴 umbrella session보다 짧은 session-scoped slice를 우선한다.
- 새 세션이 현재 세션을 대체하면 이전 세션을 `superseded` 또는 다른 종료 상태로 명시적으로 닫는다.
- 세션 closeout과 backlog closeout은 같이 움직여야 한다. 세션이 `active`를 벗어날 때는 stale `promoted` linkage를 남기지 말고 같은 closeout 경로에서 linked backlog item도 함께 갱신한다.

## 세션별 예상 산출물

- `turn-{N}.yaml`
- 실제로 peer prompt를 출력한 턴의 `turn-{N}-handoff.md`
- `state.json`
- 세션 범위 summary인 `summary.md`
- 닫힌 세션용 named summary인 `YYYY-MM-DD-{session-id}-summary.md`

최종 converged 턴에서는 summary/state 산출물이 dialogue lifecycle을 닫지만, 그것만으로 저장소 git 작업이 자동 종료되지는 않는다. 검증된 변경이 있으면 같은 최종 턴에서 `PROJECT-RULES.md`가 요구하는 commit/push/PR closeout까지 끝내거나, 구체적인 blocker를 남겨야 한다.

일반적인 active 턴은 `peer_handoff`로 닫는 것이 기본이다. 새 prompt가 없는 예외는 `final_no_handoff` 세션 closeout과 인터럽트/overflow용 `recovery_resume` packet뿐이다.

summary/state sync, closure confirmation, final wording cleanup은 별도 seal 세션이 아니라 같은 턴 closeout 작업으로 처리한다.

세션이 닫히거나 supersede될 때는 다음을 함께 처리한다.

- 다른 active session이 ownership을 이미 이어받은 경우가 아니면 linked backlog item의 `active_session_id`를 비운다
- linked backlog item이 `done`에 도달하면 `closed_by_session_id`를 기록한다
- 같은 outcome을 이어가는 것이 아니라면 duplicate sibling backlog item을 새로 만들지 않는다. outcome을 나누려는 경우에만 의도적으로 split한다

## 상태 스키마

`state.json` (both root and session-scoped) must contain:

| Field | Required | Values |
|-------|----------|--------|
| `protocol_version` | always | `"dad-v2"` |
| `session_id` | always | string |
| `session_status` | always | `active` \| `converged` \| `superseded` \| `abandoned` |
| `relay_mode` | always | `"user-bridged"` |
| `mode` | always | `autonomous` \| `hybrid` \| `supervised` |
| `scope` | always | `small` \| `medium` \| `large` |
| `current_turn` | always | integer (0 before first turn) |
| `max_turns` | always | integer |
| `last_agent` | after first turn | `codex` \| `claude-code` |
| `origin_backlog_id` | always on new sessions | backlog item id string |
| `contract_status` | always | `proposed` \| `accepted` \| `amended` |
| `packets` | always | array of relative paths |
| `closed_reason` | when status != `active` | string |
| `superseded_by` | when status == `superseded` | session-id string |

## 컨텍스트 오버플로

에이전트의 컨텍스트 창이 세션 도중 가득 차면:

1. 현재 작업을 partial turn packet으로 저장한다.
2. `confidence: low`와 `open_risks`에 오버플로 사실을 남긴다.
3. `handoff.closeout_kind: recovery_resume`를 설정하고 `handoff.prompt_artifact`는 비워 둔다.
4. 새 컨텍스트를 열고 `.prompts/04-세션-복구-재개.md`로 안전하게 재개한다.
