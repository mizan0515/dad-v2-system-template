# 03. Turn Closeout / Handoff Cleanup

## Purpose

Close out a turn consistently across the Turn Packet, state, handoff prompt, and remaining risks.

## When To Use

- Just before ending each turn
- After finishing self-iteration and preparing the peer handoff

## Procedure

1. Organize the real changes made in this turn and the verification evidence.
2. Evaluate each checkpoint as PASS / FAIL / FAIL-then-FIXED / FAIL-then-PASS.
3. Separate `issues_found`, `fixes_applied`, and `open_risks`.
4. Write `handoff.next_task` and `handoff.context` so the next agent can pick up directly.
5. If system-doc drift remains, record it as the first item in `handoff.next_task`.
6. Run the validators before writing `suggest_done: true`.
7. Verify the 6 required elements of the peer prompt and the mandatory tail block.

## Done Gate Check

- Is there a peer PASS after the most recent change?
- Is the evidence reproducible?
- Did validators pass?
- Are remaining risks hidden implicitly?
