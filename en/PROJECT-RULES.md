# Shared Project Rules

This file is the shared rule layer for all agents in this repository.

Replace the placeholders below with project-specific truth before relying on the template in production.

## Source Of Truth

If documents conflict, define your own priority order here. Example:

1. Core gameplay / product spec
2. Development plan
3. UI / UX spec
4. Feature-specific design notes

Additional expectations:

- Prefer live files over stale summaries or chat notes.
- Lower-priority docs must not redefine higher-priority canonical terms.
- If a stale summary is found, update it in the same task when practical.

## Current Repository Reality

Before trusting older summaries, migration notes, or archived prompts, fill in the live-reality facts for this repository. At minimum, document:

- which modules or directories already exist versus remain planned
- which states, services, or files are authoritative right now
- which older summaries are known to drift or lag behind the code
- any naming that is easy to confuse in code review or handoff
- any tool/runtime assumptions that are true in this repository today

If a document and the live repository disagree, prefer the live repository and update the stale document in the same task when practical.

## Project Facts

Fill in the facts that agents must never guess about, for example:

- Genre / product type
- Current milestone
- Main architecture boundaries
- Ownership of authoritative runtime state
- Critical terminology that must not be confused

## Guardrails

Document the hard rules that every agent must preserve, for example:

- What must remain data-driven
- Which services own authoritative state
- Which terms must stay distinct
- Shared-vs-local ownership rules
- Randomness / seed rules
- UI / runtime / transport separation rules
- Documentation update expectations

## Verification Expectations

Specify the minimum verification standard for this repository, for example:

- Narrowest useful test first
- Focused lint / test / smoke before broad suite
- How to report blocked verification
- What counts as sufficient evidence

## DAD Operating Reality

If this repository adopts DAD v2, record the local operating assumptions explicitly, for example:

- whether sessions are expected to be outcome-scoped, and which concrete outcomes count (for example: code changes, measurement artifacts, smoke results, config/runtime decisions, or explicit risk dispositions)
- whether meta-only sessions are disallowed or must be folded into an active work session (for example: wording-only, summary/state-sync-only, closure-seal-only, validator-noise-only)
- which cases actually justify a dedicated peer-verification step (for example: remote-visible mutation, config/runtime decision, high-risk measurement, destructive cleanup, provenance/compliance-sensitive work)
- when recovery/schema-repair sessions are allowed as the exception to the anti-churn rules
- whether short session-scoped slices are preferred over one long umbrella session
- when a fresh session should supersede the current one
- which validators are mandatory before `suggest_done: true`
- whether a final converged turn must also finish commit/push/PR or explicitly record why not
- how summaries, work-session notes, or research/inventory files must be updated
- any repository-local bootstrap or environment checks that must happen before the first session

## Git Rules

Specify the repository's git policy, for example:

- Work on a task branch, not `main`
- Commit and push after meaningful verified changes
- Open or update the task-branch PR before claiming final closeout on a converged session, unless the repository explicitly uses a different merge policy
- If PR creation is blocked, report the blocker and the exact missing step instead of silently stopping after validators
- Report clearly when unrelated dirty files block staging
