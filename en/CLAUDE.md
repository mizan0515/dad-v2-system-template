# Claude Code Contract

**IMPORTANT: Read `PROJECT-RULES.md` first.**

This file is auto-loaded by Claude Code and defines Claude Code-specific behavior for this repository.

Related files:
- `PROJECT-RULES.md` — shared rules for all agents
- `DIALOGUE-PROTOCOL.md` — thin-root Dual-Agent Dialogue v2 protocol
- `Document/DAD/` — detailed DAD schema, lifecycle, and validation references when the root protocol points there
- `AGENTS.md` — Codex-specific contract

## Repository Guardrails

- follow `PROJECT-RULES.md`
- prefer live repository state over memory
- update research / inventory docs when this repository uses them
- if a task changes DAD infrastructure, validators, slash commands, prompt templates, session schema, or agent contracts, sync the affected system docs in the same task
- if same-turn doc sync is not possible, make it the first explicit next task
- use `.prompts/10-system-doc-sync.md` as the default companion prompt for system-doc sync work
- reserve new DAD sessions for outcome-scoped work that should produce a concrete artifact, verified decision, or explicit risk disposition
- treat `Document/dialogue/backlog.json` as session-admission metadata, not as an execution log
- do not open a fresh DAD session only for wording correction, state/summary sync, closure seal, or validator-noise cleanup unless you are explicitly repairing broken DAD state
- use peer-verify-only turns only when the change is remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, or provenance/compliance-sensitive
- do not push directly to `main` / `master`

## Standalone Stance

When used directly:

- verify real files first
- state the plan when touching multiple systems
- run the narrowest useful verification after changes
- commit and push when the change is self-contained and verified
- if the work ends in a converged DAD closeout and verified changes exist, open the task-branch PR in the same closeout unless `PROJECT-RULES.md` explicitly allows a different policy
- report clearly when unrelated dirty files block staging

## Dialogue Mode

When collaborating with Codex under `DIALOGUE-PROTOCOL.md`:

- treat each DAD session as outcome-scoped work; fold closeout chores into the active execution turn instead of manufacturing a follow-on seal/sync session
- keep current-session continuation in `handoff.next_task`; use backlog only when the work needs a different session
- use a dedicated verify-only handoff only when the change is remote-visible, hard to reverse, config/runtime-sensitive, measurement-sensitive, or provenance/compliance-sensitive

1. analyze the current repository state
2. if Turn 1, draft the contract and do the first execution slice
3. if Turn 2+, review the peer turn against the checkpoints, then execute your own slice
4. self-iterate before handoff
5. save the turn packet in `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
6. if another Codex turn remains, save the exact prompt in `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md` and record that path in `handoff.prompt_artifact`
7. if another Codex turn remains, output the same Codex prompt in the same final reply that closes the turn, using the required handoff format. Do not stop at a status summary and wait for the user to ask for the next prompt.
8. if the session converges on this turn, finish the close summary/state work plus the git closeout required by `PROJECT-RULES.md` in the same turn; no-next-turn is not a reason to stop after validators
9. if system-doc drift remains, close it in the same turn or make it the first next task

## Codex Handoff Rules

When another Codex turn remains, every Codex prompt must include:

1. `Read PROJECT-RULES.md first. Then read AGENTS.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD/ references, read the needed files there too.`
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
