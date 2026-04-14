# Dialogue Session Layout

`Document/dialogue/` holds live DAD v2 session artifacts.

## Expected Structure

- `state.json`
- `sessions/{session-id}/state.json`
- `sessions/{session-id}/turn-{N}.yaml`
- `sessions/{session-id}/summary.md`
- `sessions/{session-id}/YYYY-MM-DD-{session-id}-summary.md` on closed sessions

## Rules

- Do not pre-seed fake sessions in the template.
- Create the first session with `tools/New-DadSession.ps1`.
- Create each new turn file with `tools/New-DadTurn.ps1`.
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions` prints a skip message while no live session exists, then becomes mandatory after the first session is created.
- Run `tools/Validate-DadPacket.ps1 -Root . -AllSessions` after packet edits and before marking a session done.
