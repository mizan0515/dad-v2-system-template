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
5. Save the exact peer prompt to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`, then store that path in `handoff.prompt_artifact`.
6. If system-doc drift remains, record it as the first item in `handoff.next_task`.
7. Run the validators after saving both the turn packet and the handoff prompt artifact, and again before writing `suggest_done: true`.
8. Set `handoff.ready_for_peer_verification: true` only after `handoff.next_task`, `handoff.context`, and `handoff.prompt_artifact` are all final.
9. Verify the required peer-prompt elements, the mandatory tail block, and that the final reply pastes the same text as the saved handoff artifact.

## Done Gate Check

- Is there a peer PASS after the most recent change?
- Is the evidence reproducible?
- Did validators pass?
- Are remaining risks hidden implicitly?
