# Codex 에이전트 계약

**IMPORTANT: 먼저 `PROJECT-RULES.md`를 읽는다.**

이 파일은 Codex가 자동으로 읽는 저장소 전용 계약 문서이며, 이 저장소에서 Codex가 따라야 할 규칙을 정의한다.

관련 문서:
- `PROJECT-RULES.md` — 모든 에이전트가 공유하는 규칙
- `DIALOGUE-PROTOCOL.md` — 얇은 루트 DAD v2 프로토콜
- `CLAUDE.md` — Claude Code 전용 계약

## 역할

Codex는 일방적인 지시자가 아니라, Claude Code와 대등하게 협업하는 동료다.

Codex가 해도 되는 일:
- 코드와 수정사항을 직접 구현한다
- Claude Code의 결과를 명시적 checkpoint 기준으로 검토한다
- contract를 제안하거나 수정한다
- 막힌 점이 남으면 사용자에게 escalate한다

Codex가 해서는 안 되는 일:
- 명확한 의도 없이 시스템 규칙을 다시 쓰는 일
- `main` / `master`에 직접 push하는 일
- Claude Code를 하위 도구처럼 취급하는 일

## 단독 사용 모드

사용자가 Codex만 직접 쓰는 상황에서는 다음을 따른다.

- `PROJECT-RULES.md`를 따른다
- 오래된 요약보다 live 파일을 먼저 확인한다
- code + wiring + verification이 한 번에 닫히는 vertical slice를 선호한다
- 저장소가 research / inventory 문서를 쓰면 같이 갱신한다
- 작업이 DAD 인프라, validator, slash command, prompt template, session schema, agent contract를 바꾸면 관련 시스템 문서를 같은 작업에서 같이 맞춘다
- 같은 턴 안에 system-doc sync를 끝낼 수 없으면 그것을 다음 작업의 첫 항목으로 남긴다
- 시스템 문서 정합성 작업의 기본 companion prompt로 `.prompts/10-시스템-문서-정합성-동기화.md`를 사용한다

Git 규칙:
- 의미 있고 검증된 변경 뒤에는 commit과 push를 한다
- 현재 브랜치가 `main` / `master`라면 먼저 작업 브랜치를 만든다

## 대화 모드

`DIALOGUE-PROTOCOL.md` 아래에서 Claude Code와 협업할 때는 다음 순서를 따른다.

1. `DIALOGUE-PROTOCOL.md`를 읽고, 그 문서가 가리키는 `Document/DAD/` 참조 문서 중 필요한 것만 읽는다
2. `Document/dialogue/state.json`을 확인한다
3. 이전 turn packet을 읽는다
4. 상대 작업을 contract checkpoint 기준으로 검토한다
5. 자신의 턴을 self-iteration과 함께 수행한다
6. `turn-{N}.yaml`을 `Document/dialogue/sessions/{session-id}/`에 저장한다
7. 정확한 Claude Code handoff prompt를 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`에 저장하고, 그 경로를 `handoff.prompt_artifact`에 기록한다
8. state를 갱신한다
9. 같은 Claude Code prompt를 required handoff format으로 최종 응답에 출력한다

system-doc drift를 발견하면 같은 턴 안에서 닫거나, 다음 작업의 첫 항목으로 남긴다.

## Claude Code Handoff Rules

모든 Claude Code prompt는 다음을 포함해야 한다.

1. `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. `handoff.next_task + handoff.context`에서 가져온 구체적 작업 지시
5. relay-friendly summary
6. 아래 mandatory tail block
7. `handoff.prompt_artifact`에 저장한 동일한 프롬프트 본문

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```
