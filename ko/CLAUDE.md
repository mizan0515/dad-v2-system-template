# Claude Code 계약

**IMPORTANT: 먼저 `PROJECT-RULES.md`를 읽는다.**

이 파일은 Claude Code가 자동으로 읽는 저장소 전용 계약 문서이며, 이 저장소에서 Claude Code가 따라야 할 규칙을 정의한다.

관련 문서:
- `PROJECT-RULES.md` — 모든 에이전트가 공유하는 규칙
- `DIALOGUE-PROTOCOL.md` — 얇은 루트 DAD v2 프로토콜
- `Document/DAD/` — 루트 프로토콜이 가리키는 상세 DAD 스키마, lifecycle, validation 참조
- `AGENTS.md` — Codex 전용 계약

## 저장소 Guardrails

- `PROJECT-RULES.md`를 따른다
- 기억보다 live repository state를 우선한다
- 저장소가 research / inventory 문서를 쓰면 같이 갱신한다
- 작업이 DAD 인프라, validator, slash command, prompt template, session schema, agent contract를 바꾸면 관련 시스템 문서를 같은 작업에서 같이 맞춘다
- 같은 턴 안에 system-doc sync를 끝낼 수 없으면 그것을 다음 작업의 첫 항목으로 남긴다
- 시스템 문서 정합성 작업의 기본 companion prompt로 `.prompts/10-시스템-문서-정합성-동기화.md`를 사용한다
- 새로운 DAD 세션은 구체적 artifact, 검증된 결정, 또는 명시적 risk disposition을 만드는 outcome-scoped 작업에만 연다
- `Document/dialogue/backlog.json`은 execution log가 아니라 session-admission metadata로 취급한다
- broken DAD state를 명시적으로 복구하는 경우가 아니면 wording correction, state/summary sync, closure seal, validator-noise cleanup만을 위한 새 DAD 세션은 열지 않는다
- peer-verify-only 턴은 remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, provenance/compliance-sensitive 변경일 때만 사용한다
- `main` / `master`에 직접 push하지 않는다

## 단독 사용 태도

Claude Code를 단독으로 쓸 때는 다음을 따른다.

- 실제 파일을 먼저 확인한다
- 여러 시스템을 건드릴 때는 계획을 먼저 드러낸다
- 변경 후에는 가장 좁고 유용한 검증부터 실행한다
- 변경이 self-contained하고 검증됐다면 commit과 push를 한다
- 작업이 수렴 DAD closeout으로 끝나고 검증된 변경이 있으면, `PROJECT-RULES.md`가 다른 정책을 명시하지 않는 한 같은 closeout 안에서 작업 브랜치 PR까지 연다
- 관련 없는 dirty file 때문에 staging이 막히면 그 사실을 명확히 보고한다

## 대화 모드

`DIALOGUE-PROTOCOL.md` 아래에서 Codex와 협업할 때는 다음 순서를 따른다.

- 각 DAD 세션은 outcome-scoped 작업으로 취급하고, closeout 잡무를 별도 seal/sync 세션으로 분리하지 말고 현재 execution turn 안에서 끝낸다.
- current session continuation은 `handoff.next_task`에 두고, 다른 session이 필요한 작업만 backlog로 보낸다.
- dedicated verify-only handoff는 remote-visible, 되돌리기 어려움, config/runtime-sensitive, measurement-sensitive, provenance/compliance-sensitive 작업일 때만 사용한다.

1. 현재 저장소 상태를 분석한다
2. Turn 1이면 contract를 작성하고 첫 실행 slice를 진행한다
3. Turn 2+이면 상대 turn을 checkpoint 기준으로 검토한 뒤 자신의 slice를 수행한다
4. handoff 전에 self-iteration을 수행한다
5. turn packet을 `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`에 저장한다
6. 다음 Codex 턴이 남아 있으면 정확한 prompt를 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`에 저장하고, 그 경로를 `handoff.prompt_artifact`에 기록한다
7. 다음 Codex 턴이 남아 있으면 같은 Codex prompt를 그 턴을 닫는 같은 최종 응답 안에 required handoff format으로 출력한다. 상태 요약만 남기고 사용자가 다음 프롬프트를 다시 요청하게 만들지 않는다.
8. 세션이 이번 턴에서 수렴하면 close summary/state 작업과 `PROJECT-RULES.md`가 요구하는 git closeout을 같은 턴에서 끝낸다. 다음 턴이 없다는 이유로 validator 뒤에 멈추지 않는다
9. system-doc drift가 남아 있으면 같은 턴 안에서 닫거나 다음 작업의 첫 항목으로 남긴다

## Codex Handoff Rules

다음 Codex 턴이 남아 있을 때, 모든 Codex prompt는 다음을 포함해야 한다.

1. `Read PROJECT-RULES.md first. Then read AGENTS.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD/ references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. `handoff.next_task + handoff.context`에서 가져온 구체적 작업 지시
5. relay-friendly summary
6. 아래 mandatory tail block
7. `handoff.prompt_artifact`에 저장한 동일한 프롬프트 본문

`user-bridged` 모드에서는 relay prompt가 같은 턴의 필수 산출물이다. 프롬프트를 저장했다고만 적거나 나중에 줄 수 있다고 적는 턴은 미완료다.

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```
