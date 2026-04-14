---
name: dadtpl-repeat-workflow-auto
description: "명시 호출 전용 DAD v2 judgment-light 반복 스킬이다. `$dadtpl-repeat-workflow-auto`로 직접 호출할 때 사용한다. 판단은 자동화하지만 user relay 단계는 유지된다."
---

# Repeat Workflow Auto

진행 중인 DAD v2 세션을 judgment-light 모드로 이어간다.

## 호출 방식

- 이 스킬은 명시 호출 전용이다.
- 예시: `$dadtpl-repeat-workflow-auto로 현재 DAD v2 세션을 자율 모드로 계속 진행하라.`
- 아직 세션이 없으면 먼저 `$dadtpl-dialogue-start`를 호출한다.

## 절차

1. `PROJECT-RULES.md`를 먼저 읽고, 그다음 `AGENTS.md`와 `DIALOGUE-PROTOCOL.md`를 읽는다. `DIALOGUE-PROTOCOL.md`가 `Document/DAD/` 참조를 가리키면 필요한 파일도 같이 읽는다.
2. `Document/dialogue/state.json`의 기존 세션 상태를 확인한다. 없으면 `$dadtpl-dialogue-start`를 호출한다.
3. 현재 프로젝트 상태를 자동 분석한다.
4. 자율 턴을 수행한다.
   - contract를 자동 생성하고 작업을 실행한 뒤 self-iteration을 수행한다.
   - `turn-{N}.yaml`을 저장한다.
   - 다음 peer 턴이 남아 있으면 정확한 peer prompt를 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`에 저장하고, 그 경로를 `handoff.prompt_artifact`에 기록한 뒤 같은 본문을 사용자에게 출력한다.
   - peer prompt에는 반드시 아래 7개 요소를 포함한다.
     - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
     - `Session: Document/dialogue/state.json`
     - `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
     - `handoff.next_task + handoff.context` 기반의 구체적 작업 지시
     - relay-friendly summary
     - 아래 필수 꼬리말 블록
     - `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`에 저장한 동일한 본문
5. 수렴을 명시적으로 처리한다.
   - 최종 턴이 아니면 peer handoff를 출력하고 세션을 계속한다.
   - 이번 턴이 최종 converged 턴이고 검증된 변경이 있으면, 같은 턴에서 summary/state와 task branch commit + push + PR까지 끝낸다. 단, `PROJECT-RULES.md`가 다른 정책을 명시하면 그 정책을 따른다.
   - git closeout이 막히면 validator만 통과했다고 종료 완료로 처리하지 말고 blocker와 빠진 단계를 보고한다.
6. 수렴 시 세션 summary 산출물을 `Document/dialogue/sessions/{session-id}/` 아래에 유지한다.

모든 peer prompt 끝에는 아래 꼬리말을 붙인다.

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```

## 안전 가드

1. 턴 제한을 넘기면 즉시 중단한다.
2. 같은 checkpoint가 3턴 연속 FAIL이면 자동 중단하고 사용자에게 보고한다.
3. 해결 불가능한 컴파일 에러면 중단하고 사용자에게 보고한다.
4. `main`이나 `master`에 직접 push하지 않는다.
5. 2턴 연속 품질 정체면 자동으로 다른 접근으로 전환한다.
