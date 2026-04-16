# Dialogue Session Layout

`Document/dialogue/` holds live DAD v2 session artifacts.

If you are still in initial setup, you can mostly ignore this folder until right before the first real session.

The template intentionally ships without live session data. This folder becomes important only after `tools/New-DadSession.ps1` creates the first session.

## What To Notice First

- `state.json` tracks only the currently active session
- `backlog.json` tracks future session candidates, not current execution
- `sessions/{session-id}/` stores the durable artifacts for that session
- each turn needs `turn-{N}.yaml`; turns that hand off to a peer also need the matching `turn-{N}-handoff.md`

## Expected Structure

- `state.json`
- `backlog.json`
- `sessions/{session-id}/state.json`
- `sessions/{session-id}/turn-{N}.yaml`
- `sessions/{session-id}/turn-{N}-handoff.md` when that turn emits a peer handoff
- `sessions/{session-id}/summary.md`
- `sessions/{session-id}/YYYY-MM-DD-{session-id}-summary.md` on closed sessions

## Rules

- Do not pre-seed fake sessions in the template.
- Open or continue sessions for outcome-scoped work that should leave a concrete artifact, verified decision, or explicit risk disposition.
- Backlog items are session candidates, not turn plans. Keep current-session continuation in `handoff.next_task`; use backlog only when the work needs a different session.
- Do not create a new session only for wording correction, state/summary sync, closure seal, or validator-noise cleanup unless you are repairing the DAD system itself.
- Every new non-recovery session must link to exactly one backlog item. `tools/New-DadSession.ps1` can auto-bootstrap that link only for fresh work when no reusable `now` item already exists.
- If another active session already exists, do not promote unrelated future work immediately. Leave it queued in backlog until the current session closes or is explicitly superseded.
- Do not open a backlog-only session just to groom priorities. Record the candidate during normal closeout and move on.
- Use dedicated peer-verify-only turns only when the current change is remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, or provenance/compliance-sensitive.
- Create the first session with `tools/New-DadSession.ps1`.
- Create each new turn file with `tools/New-DadTurn.ps1`.
- Save the exact peer prompt to `sessions/{session-id}/turn-{N}-handoff.md` and record that path in `handoff.prompt_artifact` for every turn that actually hands off to a peer.
- Paste that same prompt in the same final reply that closes the turn. The user should not have to ask separately for "the next prompt."
- A final converged turn may close the session without a new peer prompt. In that case, keep the close summary/state artifacts and finish the git closeout required by `PROJECT-RULES.md`.
- Keep summary/state sync, closure confirmation, and final wording cleanup inside the same closeout turn instead of opening a follow-on seal session.
- The same closeout that ends or supersedes a session should also resolve or re-queue its linked backlog item. Do not leave a dangling `promoted` item after the session is no longer active.
- Prefer short session-scoped slices. Start a fresh session when the goal or verification surface materially changes instead of stretching one session across unrelated work.
- If a new session replaces the current one, close or supersede the previous session explicitly and keep its summary artifacts.
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions` prints a skip message while no live session exists, then becomes mandatory after the first session is created.
- Run `tools/Validate-DadPacket.ps1 -Root . -AllSessions` after packet edits and before marking a session done.
- Run `tools/Validate-DadBacklog.ps1 -Root .` when backlog linkage changes or before closing a linked session.
