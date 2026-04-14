# Dialogue Session Layout

`Document/dialogue/` holds live DAD v2 session artifacts.

If you are still in initial setup, you can mostly ignore this folder until right before the first real session.

The template intentionally ships without live session data. This folder becomes important only after `tools/New-DadSession.ps1` creates the first session.

## What To Notice First

- `state.json` tracks only the currently active session
- `sessions/{session-id}/` stores the durable artifacts for that session
- each turn needs both `turn-{N}.yaml` and the matching `turn-{N}-handoff.md`

## Expected Structure

- `state.json`
- `sessions/{session-id}/state.json`
- `sessions/{session-id}/turn-{N}.yaml`
- `sessions/{session-id}/turn-{N}-handoff.md`
- `sessions/{session-id}/summary.md`
- `sessions/{session-id}/YYYY-MM-DD-{session-id}-summary.md` on closed sessions

## Rules

- Do not pre-seed fake sessions in the template.
- Create the first session with `tools/New-DadSession.ps1`.
- Create each new turn file with `tools/New-DadTurn.ps1`.
- Save the exact peer prompt for each turn to `sessions/{session-id}/turn-{N}-handoff.md` and record that path in `handoff.prompt_artifact`.
- Prefer short session-scoped slices. Start a fresh session when the goal or verification surface materially changes instead of stretching one session across unrelated work.
- If a new session replaces the current one, close or supersede the previous session explicitly and keep its summary artifacts.
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions` prints a skip message while no live session exists, then becomes mandatory after the first session is created.
- Run `tools/Validate-DadPacket.ps1 -Root . -AllSessions` after packet edits and before marking a session done.
