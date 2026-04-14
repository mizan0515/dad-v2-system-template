# 03. Turn Closeout / Handoff Cleanup

## Purpose

Close out a turn consistently across the Turn Packet, state, handoff prompt, and remaining risks.

## When To Use

- Just before ending each turn
- After finishing self-iteration and preparing the peer handoff
- Also on a final converged no-handoff turn when you need to close the packet/state cleanly without fabricating a peer prompt

## Procedure

1. Organize the real changes made in this turn and the verification evidence.
2. Evaluate each checkpoint as PASS / FAIL / FAIL-then-FIXED / FAIL-then-PASS.
3. Separate `issues_found`, `fixes_applied`, and `open_risks`.
4. If another peer turn remains, write `handoff.next_task` and `handoff.context` so the next agent can pick up directly. On a final converged no-handoff turn, leave them empty unless the repository has a specific follow-up convention.
5. If another peer turn remains, save the exact peer prompt to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`, then store that path in `handoff.prompt_artifact`. On a final converged no-handoff turn, leave `handoff.prompt_artifact` empty.
6. If system-doc drift remains, record it as the first item in `handoff.next_task`.
7. Run the validators after saving the turn packet and, when present, the handoff prompt artifact. Run them again before writing `suggest_done: true`.
8. Set `handoff.ready_for_peer_verification: true` only when another peer turn remains and `handoff.next_task`, `handoff.context`, and `handoff.prompt_artifact` are all final.
9. When a peer prompt exists, verify the required prompt elements, the mandatory tail block, and that the final reply pastes the same text as the saved handoff artifact.

## Done Gate Check

- Is there a peer PASS after the most recent change?
- Is the evidence reproducible?
- Did validators pass?
- Are remaining risks hidden implicitly?
