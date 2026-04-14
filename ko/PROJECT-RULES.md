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

## Git Rules

Specify the repository's git policy, for example:

- Work on a task branch, not `main`
- Commit and push after meaningful verified changes
- Report clearly when unrelated dirty files block staging
