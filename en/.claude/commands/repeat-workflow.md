---
description: Repeat Dual-Agent Dialogue v2 symmetric turns
argument-hint: "[turn count, default 5]"
---

# /repeat-workflow

Repeatedly execute a symmetric-turn collaboration session under the Dual-Agent Dialogue v2 protocol.

## Arguments

- `$ARGUMENTS` = number of turns to repeat (1–10). Defaults to 5 if empty.

## Procedure

1. Read `PROJECT-RULES.md` first, then read `CLAUDE.md` and `DIALOGUE-PROTOCOL.md` to internalize the v2 protocol.
2. Check the existing session state in `Document/dialogue/state.json` (if absent, start a new session with `/dialogue-start`).
3. Analyze the current project state.
4. For each turn:
   a. **Peer work feedback**: PASS/FAIL against Contract checkpoints
   b. **Own plan + execution**: run the self-iteration loop
   c. **Save Turn Packet**: `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
   d. **Save peer prompt artifact**: write the exact prompt body to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`, record that path in `handoff.prompt_artifact`, and keep `handoff.ready_for_peer_verification` false until `handoff.next_task` and `handoff.context` are final.
   e. **Generate peer prompt**: output the same prompt body to the user (no CLI wrapper).
      The prompt must include these 7 elements:
      - `Read PROJECT-RULES.md first. Then read AGENTS.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
      - `Session: Document/dialogue/state.json`
      - `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
      - Concrete task instruction (`handoff.next_task + handoff.context`)
      - A ~10-line relay-friendly summary
      - The mandatory tail block below
      - The exact same body saved in `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`
      Append this tail block at the end of the prompt:
      ```
      ---
      If you find any gap or improvement, fix it directly and report the diff.
      If nothing needs to change, state explicitly: "No change needed, PASS".
      Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
      ```
   f. **User shares Codex result**: feedback → next turn
   g. **Convergence decision**: all checkpoints PASS + both sides done → complete session closeout. If another peer turn remains, emit the next handoff. If this is the final converged turn, finish summary/state updates plus task-branch commit + push + PR in the same turn, or report the exact blocker.
5. On finish, record the session summary under `Document/dialogue/sessions/{session-id}/`.

## Safety Guards

1. Hard turn limit: stop when `$ARGUMENTS` is exceeded
2. Two consecutive turns of quality stagnation → ESCALATE to user
3. Three consecutive FAILs on the same checkpoint → auto-stop
4. Compile errors → resolve first, then proceed
5. No direct push to main branch

## User Intervention Points

- Before each turn: user may adjust direction
- When Codex result is shared: extra feedback possible (`user note:`)
- On ESCALATE: user decides

## Invocation Examples

```
/repeat-workflow 5
/repeat-workflow 3
/repeat-workflow
```
