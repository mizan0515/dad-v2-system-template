# 02. Session Start / Contract Drafting

## Purpose

When starting a new DAD v2 session, establish the first Turn's Contract and execution scope without being under-scoped.

## When To Use

- When starting a new session
- When superseding an existing session and moving to a new one
- When the user's request is too short or ambiguous to turn directly into checkpoints

## Procedure

1. Read `PROJECT-RULES.md`, `AGENTS.md` or `CLAUDE.md`, and `DIALOGUE-PROTOCOL.md`.
2. Inspect live file state and the current branch.
3. Build a `task_model` first if needed.
4. Produce 3–5 checkpoints anchored on `success_shape`, `major_risks`, and `out_of_scope`.
5. In Turn 1, also execute the first feasible vertical slice.
6. Record the Contract draft and first execution evidence together in the Turn Packet.

## Checkpoint Quality Standards

- Must be judgeable against a concrete implementation artifact.
- The verification method must live alongside the checkpoint itself.
- Do not silently pull `out_of_scope` items back in.
- If project documentation drift is visible, surface it as a separate checkpoint or as a follow-up task.
