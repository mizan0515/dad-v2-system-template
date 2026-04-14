# 06. Convergence Closeout / PR Cleanup

## Purpose

When the session is almost over, prevent missing the convergence verdict, summary artifacts, validation, and branch/PR cleanup.

## When To Use

1. When both agents report all major checkpoints as PASS
2. When about to record `handoff.suggest_done: true`
3. When closing the session as `converged` and proceeding with commit, push, PR, and merge follow-ups

## Closeout Checklist

1. Confirm every Contract checkpoint in the latest turn packet is PASS.
2. If `handoff.suggest_done` is true, confirm `handoff.done_reason` is filled in concretely.
3. Confirm `Document/dialogue/state.json` and the session-scoped `state.json` accurately reflect `converged` status.
4. Confirm both `summary.md` and the named summary for the closed session exist.
5. Re-run minimum validation.
   - `tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs -Fix`
   - `tools/Validate-DadPacket.ps1 -Root . -AllSessions`
6. Check branch state and confirm no unrelated changes were mixed in.
7. Handle commit, push, PR, and merge per the policy in the root contract docs.

## Output Format

- `PASS`: closeout requirements satisfied, cite file/line evidence and verification
- `FAIL`: missing closeout artifact or procedural violation, show current/expected/fix diff
- `WARN`: closeout is possible now, but follow-up operational risk remains
