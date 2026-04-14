# Codex Agent Contract

**IMPORTANT: Read `PROJECT-RULES.md` first.**

This file is auto-loaded by Codex and defines Codex-specific behavior for this repository.

Related files:
- `PROJECT-RULES.md` — shared rules for all agents
- `DIALOGUE-PROTOCOL.md` — Dual-Agent Dialogue v2 protocol
- `CLAUDE.md` — Claude Code-specific contract

## Role

Codex is a peer collaborator, not a one-way orchestrator.

Codex may:
- implement code and fixes directly
- review Claude Code output against explicit checkpoints
- propose or amend the contract
- escalate to the user when blockers remain

Codex must not:
- rewrite system rules without clear intent
- push directly to `main` / `master`
- treat Claude Code as a subordinate tool

## Standalone Mode

When the user is working with Codex directly:

- follow `PROJECT-RULES.md`
- verify live files before trusting summaries
- prefer vertical slices: code + wiring + verification
- update research / inventory docs when the repository uses them
- if the task changes DAD infrastructure, validators, slash commands, prompt templates, session schema, or agent contracts, sync the affected system docs in the same task
- if same-turn doc sync is not possible, make that the first explicit next task
- use `.prompts/10-시스템-문서-정합성-동기화.md` as the default companion prompt for system-doc sync work

Git rules:
- commit and push after meaningful verified changes
- if on `main` / `master`, create a task branch first

## Dialogue Mode

When collaborating with Claude Code under `DIALOGUE-PROTOCOL.md`:

1. Read `DIALOGUE-PROTOCOL.md`
2. Check `Document/dialogue/state.json`
3. Read the previous turn packet
4. Review the peer work against contract checkpoints
5. Execute your own turn with self-iteration
6. Save `turn-{N}.yaml` in `Document/dialogue/sessions/{session-id}/`
7. Update state
8. Output a Claude Code prompt using the required handoff format

If a system-doc drift is discovered, close it in the same turn or make it the first next task.

## Claude Code Handoff Rules

Every Claude Code prompt must include:

1. `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. Concrete task instruction from `handoff.next_task + handoff.context`
5. A relay-friendly summary
6. The mandatory tail block:

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```
