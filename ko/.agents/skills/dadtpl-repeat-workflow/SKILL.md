---
name: dadtpl-repeat-workflow
description: "Explicit-invocation skill to execute the next turn of an active DAD v2 session. Use when directly invoked via `$dadtpl-repeat-workflow`. Triggers: \"next turn\", \"repeat workflow\", \"continue turn\", \"continue session\". Do not use if no session exists."
---

# Repeat Workflow

Execute the next turn of an ongoing DAD v2 session.

## Invocation

- This skill is explicit-invocation only.
- Example: `Run the next turn of the current DAD v2 session via $dadtpl-repeat-workflow.`
- If no session exists yet, call `$dadtpl-dialogue-start` first.

## Procedure

1. Read `PROJECT-RULES.md` first, then read `AGENTS.md` and `DIALOGUE-PROTOCOL.md`. If `DIALOGUE-PROTOCOL.md` points to `Document/DAD/` references, read the needed files there too.
2. Check the existing session state in `Document/dialogue/state.json`. If it is absent, direct the user to `$dadtpl-dialogue-start`.
3. Read the previous turn packet from `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`.
4. Perform the current turn:
   - Review peer work against the contract checkpoints with PASS/FAIL evidence.
   - Execute your own slice with self-iteration.
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
   - If another peer turn remains, emit the handoff and continue the session.
   - If this is the final converged turn with verified changes, set `handoff.closeout_kind: final_no_handoff` and finish the close summary/state work plus task-branch commit + push + PR in the same turn unless `PROJECT-RULES.md` explicitly allows another policy.
   - If commit, push, or PR creation is blocked, record the exact blocker and missing step instead of calling the closeout complete.
   - Use `recovery_resume` only when interruption or context overflow prevents a peer handoff on this turn.
6. On convergence, keep the session summary artifacts under `Document/dialogue/sessions/{session-id}/`.

Append this tail block at the end of every peer prompt:

```text
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```

## Safety Guards

1. Stop when the per-scope turn limit is exceeded.
2. Two consecutive turns of quality stagnation require ESCALATE to the user.
3. Three consecutive FAILs on the same checkpoint require auto-stop.
4. Resolve compile errors before proceeding.
5. Never push directly to `main` or `master`.
