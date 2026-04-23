# Template Interaction Guide

## Why this exists

Real projects usually combine three layers:

1. outer automation/operator control
2. DAD runtime/session contract
3. downstream product runtime and governance

This template owns only layer 2.

## Put the lesson in the right layer

Use `autopilot-template` for:

- compact status surfaces
- decision-PR operator control
- bounded wait and wake rules
- stale-signal checks
- generic doctor checks

Use this DAD template for:

- packet and state schema rules
- handoff and closeout semantics
- validator behavior
- prompt artifact requirements
- backlog/session admission rules

Keep it in the downstream product repo for:

- product dashboards
- product prompts
- product evidence wording
- product route heuristics
- domain governance wording

## Adoption order for a real repo

1. copy `autopilot-template` if you want an outer loop
2. copy one DAD variant from this repository
3. adapt root contracts to the real repo
4. define compact status artifacts in the outer loop wrapper
5. keep product-local dashboards and evidence local

## Upstream test

Before moving a live-project lesson into this template, ask:

1. Does it change reusable DAD behavior?
2. Can it be explained without one product's domain?
3. Can both `en/` and `ko/` carry it symmetrically?

If not, it does not belong here.
