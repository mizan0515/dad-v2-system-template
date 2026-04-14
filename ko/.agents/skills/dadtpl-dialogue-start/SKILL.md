---
name: dadtpl-dialogue-start
description: "명시 호출 전용 DAD v2 세션 시작 스킬이다. `$dadtpl-dialogue-start`로 직접 호출할 때 사용한다. Codex가 Turn 1을 수행하고 Claude Code handoff prompt를 만든다."
---

# Dialogue Start

Codex가 Turn 1을 맡는 DAD v2 세션을 시작한다.

## 호출 방식

- 이 스킬은 명시 호출 전용이다.
- 예시: `$dadtpl-dialogue-start로 DAD v2 세션을 시작하라.`

## 전제

- 실행 주체는 Codex다.
- Codex 계약은 `AGENTS.md`, Claude Code 계약은 `CLAUDE.md`다.

## 절차

1. `PROJECT-RULES.md`를 먼저 읽고, 그다음 `AGENTS.md`와 `DIALOGUE-PROTOCOL.md`를 읽는다. `DIALOGUE-PROTOCOL.md`가 `Document/DAD/` 참조를 가리키면 필요한 파일도 같이 읽는다.
2. 현재 프로젝트 상태를 분석한다. git 상태, 최근 작업 흐름, 검증 로그, 저장소 전용 reference 문서를 포함한다.
3. 작업 scope를 판단한다.
4. Turn 1을 수행한다.
   - medium 또는 large scope면 sprint contract를 작성한다.
   - 첫 slice를 계획하고 실행한다.
   - 현재 checkpoint가 만족될 때까지 self-iteration을 수행한다.
   - `Document/dialogue/sessions/{session-id}/turn-01.yaml`을 저장한다.
5. `Document/dialogue/state.json`을 초기화하거나 갱신한다.
6. 정확한 Claude Code용 프롬프트를 `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`에 저장하고, 그 경로를 `handoff.prompt_artifact`에 기록한다. `handoff.ready_for_peer_verification: true`는 `handoff.next_task`, `handoff.context`, `handoff.prompt_artifact`가 모두 최종 확정된 뒤에만 설정한다.
7. 같은 프롬프트 본문을 사용자에게 출력한다.
   - 프롬프트에는 반드시 아래 7개 요소를 포함한다.
     - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
     - `Session: Document/dialogue/state.json`
     - `Previous turn: Document/dialogue/sessions/{session-id}/turn-01.yaml`
     - `handoff.next_task + handoff.context` 기반의 구체적 작업 지시
     - relay-friendly summary
     - 아래 필수 꼬리말 블록
     - `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`에 저장한 동일한 본문

프롬프트 끝에는 아래 꼬리말을 붙인다.

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```

## 브랜치 규칙

- `main`이나 `master`에 직접 push하지 않는다.
- 이후 세션이 검증된 변경과 함께 수렴하면, 최종 converged 턴은 `PROJECT-RULES.md`가 예외를 명시하지 않는 한 task branch commit + push + PR까지 마쳐야 한다.
