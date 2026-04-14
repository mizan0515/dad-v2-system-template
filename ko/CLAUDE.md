# Claude Code Contract

**IMPORTANT: Read `PROJECT-RULES.md` first.**

This file is auto-loaded by Claude Code and defines Claude Code-specific behavior for this repository.

Related files:
- `PROJECT-RULES.md` — shared rules for all agents
- `DIALOGUE-PROTOCOL.md` — thin-root Dual-Agent Dialogue v2 protocol
- `Document/DAD/` — 루트 프로토콜이 가리키는 상세 DAD 스키마, lifecycle, validation 참조
- `AGENTS.md` — Codex-specific contract

## Repository Guardrails

- follow `PROJECT-RULES.md`
- prefer live repository state over memory
- update research / inventory docs when this repository uses them
- if a task changes DAD infrastructure, validators, slash commands, prompt templates, session schema, or agent contracts, sync the affected system docs in the same task
- if same-turn doc sync is not possible, make it the first explicit next task
- use `.prompts/10-시스템-문서-정합성-동기화.md` as the default companion prompt for system-doc sync work
- do not push directly to `main` / `master`

## Standalone Stance

When used directly:

- verify real files first
- state the plan when touching multiple systems
- run the narrowest useful verification after changes
- commit and push when the change is self-contained and verified
- report clearly when unrelated dirty files block staging

## Dialogue Mode

When collaborating with Codex under `DIALOGUE-PROTOCOL.md`:

1. analyze the current repository state
2. if Turn 1, draft the contract and do the first execution slice
3. if Turn 2+, review the peer turn against the checkpoints, then execute your own slice
4. self-iterate before handoff
5. save the turn packet in `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
6. 정확한 Codex prompt를 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`로 저장하고 그 경로를 `handoff.prompt_artifact`에 기록한다
7. 같은 Codex prompt를 required handoff format으로 출력한다
8. if system-doc drift remains, close it in the same turn or make it the first next task

## Codex Handoff Rules

Every Codex prompt must include:

1. `Read PROJECT-RULES.md first. Then read AGENTS.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD/ references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. Concrete task instruction from `handoff.next_task + handoff.context`
5. A relay-friendly summary
6. The mandatory tail block:
7. `handoff.prompt_artifact`에 저장한 동일한 프롬프트 본문

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```
