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
3. Decide whether the proposed session is outcome-scoped. If the work is only wording correction, state/summary sync, closure seal, or validator-noise cleanup, fold it into the active execution session unless you are explicitly repairing broken DAD state or packet/schema drift.
4. Judge task scope.
5. If `Document/dialogue/state.json` already points to an active session, do not silently open a second one. Continue the active session or supersede/repair the linkage explicitly first.
6. Create the session through `tools/New-DadSession.ps1` and make sure it links exactly one backlog item in `Document/dialogue/backlog.json`. Auto-bootstrap is only for fresh work when no reusable `now` or equivalent queued candidate already exists.
7. Execute Turn 1:
   - Draft the sprint contract for medium or large scope.
   - Include at least one checkpoint naming the concrete artifact, verified decision, or risk disposition that justifies opening the session.
   - Plan and execute the first slice.
   - Self-iterate until the current checkpoints are satisfied.
   - Save `Document/dialogue/sessions/{session-id}/turn-01.yaml`.
8. Initialize or update `Document/dialogue/state.json`.
9. If another peer turn remains, use a handoff only for outcome work. Keep `handoff.next_task` for current-session continuation; if newly discovered work needs a different future session, record it in `Document/dialogue/backlog.json` instead. Do not generate a verify-only / wording-only / sync-only / seal-only follow-up unless the remaining work is risk-gated or the DAD system itself needs repair.
10. Set `handoff.closeout_kind: peer_handoff`, save the exact Claude Code-facing prompt to `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`, record that path in `handoff.prompt_artifact`, and set `handoff.ready_for_peer_verification: true` only after `handoff.next_task`, `handoff.context`, and `handoff.prompt_artifact` are all final.
11. Output the same prompt body to the user in the same final reply that closes Turn 1. Do not stop at a status summary and wait for the user to ask for the next prompt.
   - The prompt must include these 7 elements:
     - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
     - `Session: Document/dialogue/state.json`
     - `Previous turn: Document/dialogue/sessions/{session-id}/turn-01.yaml`
     - Concrete task instruction from `handoff.next_task + handoff.context`
     - A relay-friendly summary
     - The mandatory tail block below
     - The exact same body saved in `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`

Append this tail block at the end of the prompt:

```text
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
