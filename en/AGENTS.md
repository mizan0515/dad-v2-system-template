# Codex Agent Contract

**IMPORTANT: Read `PROJECT-RULES.md` first.**

This file is auto-loaded by Codex and defines Codex-specific behavior for this repository.

Related files:
- `PROJECT-RULES.md` — shared rules for all agents
- `DIALOGUE-PROTOCOL.md` — thin-root Dual-Agent Dialogue v2 protocol
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
- use `.prompts/10-system-doc-sync.md` as the default companion prompt for system-doc sync work

Git rules:
- commit and push after meaningful verified changes
- if on `main` / `master`, create a task branch first

## Dialogue Mode

When collaborating with Claude Code under `DIALOGUE-PROTOCOL.md`:

1. Read `DIALOGUE-PROTOCOL.md`, then read the needed `Document/DAD/` reference files it points to
2. Check `Document/dialogue/state.json`
3. Read the previous turn packet
4. Review the peer work against contract checkpoints
5. Execute your own turn with self-iteration
6. Save `turn-{N}.yaml` in `Document/dialogue/sessions/{session-id}/`
7. Save the exact Claude Code handoff prompt to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md` and record that path in `handoff.prompt_artifact`
8. Update state
9. Output the same Claude Code prompt in the final reply using the required handoff format

If a system-doc drift is discovered, close it in the same turn or make it the first next task.

## Claude Code Handoff Rules

Every Claude Code prompt must include:

1. `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. Concrete task instruction from `handoff.next_task + handoff.context`
5. A relay-friendly summary
6. The mandatory tail block:
7. The exact text also saved to `handoff.prompt_artifact`

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```
