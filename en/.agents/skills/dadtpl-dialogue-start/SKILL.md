---
name: dadtpl-dialogue-start
description: "Explicit-invocation skill to start a DAD v2 session with Claude Code. Use when directly invoked via `$dadtpl-dialogue-start`. Use it for medium or large tasks where an external critical review is valuable."
---

# Dialogue Start

Start a DAD v2 session where Codex takes Turn 1.

## Invocation

- This skill is explicit-invocation only.
- Example: `Start a DAD v2 session via $dadtpl-dialogue-start.`

## Preconditions

- The acting agent is Codex.
- The Codex contract is `AGENTS.md`; Claude Code's contract is `CLAUDE.md`.

## Procedure

1. Read `PROJECT-RULES.md` first, then read `AGENTS.md` and `DIALOGUE-PROTOCOL.md`. If `DIALOGUE-PROTOCOL.md` points to `Document/DAD/` references, read the needed files there too.
2. Analyze the current project state, including git status, recent work, verification logs, and repository-specific reference docs when present.
3. Judge task scope.
4. Execute Turn 1:
   - Draft the sprint contract for medium or large scope.
   - Plan and execute the first slice.
   - Self-iterate until the current checkpoints are satisfied.
   - Save `Document/dialogue/sessions/{session-id}/turn-01.yaml`.
5. Initialize or update `Document/dialogue/state.json`.
6. Save the exact Claude Code-facing prompt to `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`, record that path in `handoff.prompt_artifact`, and set `handoff.ready_for_peer_verification: true` only after `handoff.next_task`, `handoff.context`, and `handoff.prompt_artifact` are all final.
7. Output the same prompt body to the user.
   - The prompt must include these 7 elements:
     - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
     - `Session: Document/dialogue/state.json`
     - `Previous turn: Document/dialogue/sessions/{session-id}/turn-01.yaml`
     - Concrete task instruction from `handoff.next_task + handoff.context`
     - A relay-friendly summary
     - The mandatory tail block below
     - The exact same body saved in `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`

Append this tail block at the end of the prompt:

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```

## Branch Rules

- Never push directly to `main` or `master`.
- If the session later converges with verified changes, the final converged turn still needs task-branch commit + push + PR unless `PROJECT-RULES.md` explicitly allows a different policy.

## Session Modes

- Autonomous: only ESCALATE reaches the user.
- Supervised: every convergence needs user confirmation.
- Hybrid: confirm only when scope is large or confidence is low.
