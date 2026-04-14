---
name: dadtpl-repeat-workflow
description: "Explicit-invocation skill to repeat DAD v2 symmetric turns. Use when directly invoked via `$dadtpl-repeat-workflow`. Executes the next turn of an ongoing dialogue session. Triggers: \"next turn\", \"repeat workflow\", \"continue turn\", \"continue session\". Do not use if no session exists."
---

# Repeat Workflow (symmetric-turn repetition)

Execute the next turn of an ongoing DAD v2 session.

## Invocation

- This skill is **explicit-invocation only**, not auto-suggested.
- Example: `Run the next turn of the current DAD v2 session via $dadtpl-repeat-workflow.`
- If no session exists yet, call `$dadtpl-dialogue-start` first.

## Procedure

1. Read `PROJECT-RULES.md` first, then read `AGENTS.md` and `DIALOGUE-PROTOCOL.md`.
2. Check existing session state in `Document/dialogue/state.json` (if absent, direct the user to `$dadtpl-dialogue-start`).
3. Read the previous Turn Packet (`Document/dialogue/sessions/{session-id}/turn-{N}.yaml`).
4. Perform the current turn:
   a. **Peer work feedback**: PASS/FAIL + evidence against Contract checkpoints
   b. **Own plan + execution**: run the self-iteration loop
   c. **Save Turn Packet**: `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
   d. **Generate peer prompt**: output the prompt body to the user (no CLI wrapper)
      - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md.`
      - `Session: Document/dialogue/state.json`
      - `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
      - Concrete task instruction (`handoff.next_task + handoff.context`)
      - A ~10-line relay-friendly summary
      - The mandatory tail block below
   e. **Convergence decision**: all checkpoints PASS + both sides done → commit + push to task branch + open PR (no direct push to main)

   Append this tail block at the end of the peer prompt:
   ```
   ---
   If you find any gap or improvement, fix it directly and report the diff.
   If nothing needs to change, state explicitly: "No change needed, PASS".
   Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
   ```

5. On convergence, record the session summary under `Document/dialogue/sessions/{session-id}/`.

## Safety Guards

1. Hard turn limit: stop when the per-scope max is exceeded
2. Two consecutive turns of quality stagnation → ESCALATE to user
3. Three consecutive FAILs on the same checkpoint → auto-stop
4. Compile errors → resolve first, then proceed
5. No direct push to main branch
