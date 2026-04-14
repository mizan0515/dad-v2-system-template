# DAD 상태와 세션 라이프사이클

공유 상태, 세션 디렉터리, 라이프사이클 규칙은 이 파일을 기준으로 본다.

## 공유 상태

상태 파일: `Document/dialogue/state.json`

세션 디렉터리: `Document/dialogue/sessions/{session-id}/`

루트 `state.json`은 현재 활성 세션만 추적한다. 새 세션이 생성되면 루트 state는 덮어쓰고, 이전 세션 상태는 `sessions/{session-id}/state.json`에 남긴다.

## 운영 선호 규칙

- 목표, 검증 표면, 작업 소유 범위가 크게 바뀌면 하나의 긴 umbrella session보다 짧은 session-scoped slice를 우선한다.
- 새 세션이 현재 세션을 대체하면 이전 세션을 `superseded` 또는 다른 종료 상태로 명시적으로 닫는다.

## 세션별 예상 산출물

- `turn-{N}.yaml`
- 턴 종료 시 실제로 출력한 peer prompt를 저장한 `turn-{N}-handoff.md`
- `state.json`
- 세션 범위 summary인 `summary.md`
- 닫힌 세션용 named summary인 `YYYY-MM-DD-{session-id}-summary.md`

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
| `contract_status` | always | `proposed` \| `accepted` \| `amended` |
| `packets` | always | array of relative paths |
| `closed_reason` | when status != `active` | string |
| `superseded_by` | when status == `superseded` | session-id string |

## 컨텍스트 오버플로

에이전트의 컨텍스트 창이 세션 도중 가득 차면:

1. 현재 작업을 partial turn packet으로 저장한다.
2. `confidence: low`와 `open_risks`에 오버플로 사실을 남긴다.
3. 새 컨텍스트를 열고 `.prompts/04-세션-복구-재개.md`로 안전하게 재개한다.
