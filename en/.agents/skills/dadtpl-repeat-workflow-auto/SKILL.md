---
name: dadtpl-repeat-workflow-auto
description: "Explicit-invocation skill for DAD v2 judgment-light repetition. Use when directly invoked via `$dadtpl-repeat-workflow-auto`. It automates judgment; only ESCALATE reaches the user. Note: the user relay step is still required."
---

# Repeat Workflow Auto

Continue an active DAD v2 session in judgment-light mode.

## Invocation

- This skill is explicit-invocation only.
- Example: `Continue the current DAD v2 session in autonomous mode via $dadtpl-repeat-workflow-auto.`
- If no session exists yet, call `$dadtpl-dialogue-start` first.

## Procedure

1. Read `PROJECT-RULES.md` first, then read `AGENTS.md` and `DIALOGUE-PROTOCOL.md`. If `DIALOGUE-PROTOCOL.md` points to `Document/DAD/` references, read the needed files there too.
2. Check the existing session state in `Document/dialogue/state.json`. If it is absent, call `$dadtpl-dialogue-start`.
3. Automatically analyze the current project state without overriding explicit user direction or backlog admission state.
4. Execute autonomous turns:
   - Auto-generate the contract, verify that the next step is still outcome-scoped, choose the highest-value next slice inside the active session and explicit user direction, execute work, self-iterate, and decide whether another peer turn is needed.
   - Save `turn-{N}.yaml`.
   - If the only remaining work is wording correction, state/summary sync, closure seal, or validator-noise cleanup, finish it inside the current execution turn unless the DAD system itself needs repair.
   - Keep `handoff.next_task` for work that stays inside the current session. If newly discovered work needs a different future session, record it in `Document/dialogue/backlog.json` instead.
   - If this closeout ends, blocks, or supersedes the session, resolve or re-queue the linked backlog item in the same closeout path rather than leaving a stale `promoted` owner behind.
   - If another peer turn remains, set `handoff.closeout_kind: peer_handoff`, save the exact peer prompt to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`, record that path in `handoff.prompt_artifact`, and output the same body to the user in the same closeout reply.
   - Use a dedicated verify-only handoff only when the remaining work is remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, or provenance/compliance-sensitive.
   - The peer prompt must include these 7 elements:
     - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
     - `Session: Document/dialogue/state.json`
     - `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
     - Concrete task instruction from `handoff.next_task + handoff.context`
     - A relay-friendly summary
     - The mandatory tail block below
     - The exact same body saved in `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`
5. Handle convergence explicitly:
   - If this is not the final turn, emit the peer handoff and continue.
   - If this is the final converged turn with verified changes, set `handoff.closeout_kind: final_no_handoff` and finish summary/state updates plus task-branch commit + push + PR in the same turn unless `PROJECT-RULES.md` explicitly says otherwise.
   - If git closeout is blocked, report the exact blocker and missing step instead of treating validators alone as complete closeout.
   - Use `recovery_resume` only when interruption or context overflow prevents a peer handoff on this turn.
6. On convergence, keep the session summary artifacts under `Document/dialogue/sessions/{session-id}/`.

Append this tail block at the end of every peer prompt:

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```

## Safety Guards

1. Stop immediately when the turn limit is exceeded.
2. Three consecutive FAILs on the same checkpoint require auto-stop and a user report.
3. Unresolvable compile errors require stop and user report.
4. Never push directly to `main` or `master`.
5. Two consecutive turns of quality stagnation require an automatic approach change.
