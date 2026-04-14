# Dual-Agent Dialogue Protocol (DAD v2)

Codex와 Claude Code의 대칭 턴 협업을 위한 얇은 루트 프로토콜 문서.

이 루트 문서는 한 번에 읽을 수 있는 크기로 유지한다. 상세 스키마, lifecycle, validation 규칙은 `Document/DAD/` 아래에 둔다.

## 핵심 원칙

1. Symmetric turns: 두 에이전트 모두 계획하고, 실행하고, 평가한다.
2. Sprint Contract: done 상태는 구체적인 checkpoint로 표현한다.
3. Self-iteration: 각 에이전트는 handoff 전에 자기 작업을 스스로 검증한다.
4. Live files first: 오래된 기억보다 현재 저장소 현실을 우선한다.
5. Schema discipline: packet과 state는 validator를 통과해야 한다.
6. System-doc sync: DAD 인프라, validator, command, prompt template, agent contract가 바뀌면 관련 문서를 같은 작업에서 같이 맞추거나 다음 작업의 첫 항목으로 남긴다.

## 턴 흐름

- Turn 1: 상태를 분석하고, contract를 초안 작성하고, 첫 slice를 실행하고, self-iterate한 뒤 packet을 쓰고 peer prompt를 출력한다.
- Turn 2+: 상대 turn을 checkpoint 기준으로 검토하고, 자신의 slice를 실행하고, self-iterate한 뒤 packet을 쓰고 peer prompt를 출력한다.

## 필수 규칙

- `my_work`는 필수다.
- `suggest_done`, `done_reason`는 `handoff` 안에만 둔다.
- `suggest_done: true`면 `done_reason`이 필요하다.
- 닫힌 세션에는 summary artifact가 필요하다.
- 루트 `Document/dialogue/state.json`은 현재 활성 세션만 추적한다.
- 목표나 검증 표면이 크게 바뀌면 하나의 긴 umbrella session보다 짧은 session-scoped slice를 우선한다.
- 새 세션이 현재 세션을 대체하면 이전 세션을 `superseded` 또는 다른 종료 상태로 명시적으로 닫는다.

## Peer Prompt 규칙

모든 peer prompt는 아래를 포함해야 한다.

1. `Read PROJECT-RULES.md first. Then read {agent-contract}.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. 구체적인 `handoff.next_task + handoff.context`
5. relay-friendly summary
6. mandatory tail block
7. `handoff.prompt_artifact`에 저장한 동일한 프롬프트 본문

필수 tail block:

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```

## 검증

- `tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

최소 검증 시점:

1. turn packet 저장 직후
2. `handoff.prompt_artifact`가 가리키는 프롬프트 artifact 저장 직후
3. `suggest_done: true`를 기록하기 직전
4. 복구 세션을 재개하기 직전

## 상세 참조

- `Document/DAD/README.md`
- `Document/DAD/PACKET-SCHEMA.md`
- `Document/DAD/STATE-AND-LIFECYCLE.md`
- `Document/DAD/VALIDATION-AND-PROMPTS.md`
