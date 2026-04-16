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
- reserve new DAD sessions for outcome-scoped work that should produce a concrete artifact, verified decision, or explicit risk disposition
- treat `Document/dialogue/backlog.json` as session-admission metadata, not as an execution log
- do not open a fresh DAD session only for wording correction, state/summary sync, closure seal, or validator-noise cleanup unless you are explicitly repairing broken DAD state
- use peer-verify-only turns only when the change is remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, or provenance/compliance-sensitive

Git rules:
- commit and push after meaningful verified changes
- if on `main` / `master`, create a task branch first
- when a DAD session converges on your turn and verified changes exist, complete task-branch commit + push + PR in the same closeout unless `PROJECT-RULES.md` explicitly says otherwise
- if PR creation is blocked, record the blocker and the exact missing step instead of silently calling the closeout complete

## Dialogue Mode

When collaborating with Claude Code under `DIALOGUE-PROTOCOL.md`:

- treat each DAD session as outcome-scoped work; fold closeout chores into the active execution turn instead of manufacturing a follow-on seal/sync session
- keep current-session continuation in `handoff.next_task`; use backlog only when the work needs a different session
- use a dedicated verify-only handoff only when the change is remote-visible, hard to reverse, config/runtime-sensitive, measurement-sensitive, or provenance/compliance-sensitive

1. Read `DIALOGUE-PROTOCOL.md`, then read the needed `Document/DAD/` reference files it points to
2. Check `Document/dialogue/state.json`
3. Read the previous turn packet
4. Review the peer work against contract checkpoints
5. Execute your own turn with self-iteration
6. Save `turn-{N}.yaml` in `Document/dialogue/sessions/{session-id}/`
7. If another Claude Code turn remains, save the exact handoff prompt to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md` and record that path in `handoff.prompt_artifact`
8. Update state
9. If another Claude Code turn remains, output the same Claude Code prompt in the same final reply that closes the turn, using the required handoff format. Do not stop at a status summary and wait for the user to ask for the next prompt.
10. If the session converges on this turn, finish the close summary/state work and the git closeout required by `PROJECT-RULES.md` in the same turn. No-next-turn is not a reason to defer commit/push/PR.

If a system-doc drift is discovered, close it in the same turn or make it the first next task.

## Claude Code Handoff Rules

When another Claude Code turn remains, every Claude Code prompt must include:

1. `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. Concrete task instruction from `handoff.next_task + handoff.context`
5. A relay-friendly summary
6. The mandatory tail block:
7. The exact text also saved to `handoff.prompt_artifact`

In `user-bridged` mode, the relay prompt is a required same-turn deliverable. A turn that says the prompt was saved or can be provided later is incomplete.

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```
