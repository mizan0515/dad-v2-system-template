# Template Interaction Guide

## Purpose

This repository is the reusable DAD runtime/session layer.
It is meant to cooperate with:

- an outer automation/operator layer such as `autopilot-template`
- a downstream product repository that owns domain code and domain operations

Use this file to decide whether a lesson learned in a live repo belongs here,
belongs in `autopilot-template`, or must stay product-local.

## Three-Layer Model

### Layer 1: Autopilot / Operator Control

Owned by `autopilot-template`.

Typical responsibilities:

- wake/sleep pacing
- active-task dispatch
- operator-decision routing
- compact status and done markers
- doctor checks
- retry budgets
- stale-signal cleanup

Do not upstream these into this repository unless they change the DAD runtime
contract itself.

### Layer 2: DAD Runtime / Session Contract

Owned by this repository.

Typical responsibilities:

- peer-symmetric turn structure
- packet and state schema
- handoff semantics
- validator rules
- prompt artifact rules
- backlog admission rules
- peer prompt conventions

This is the correct home only when the lesson changes reusable peer-collaboration
behavior across products.

### Layer 3: Product Runtime / Operations

Owned by the downstream product repo.

Typical responsibilities:

- product prompts
- product dashboards
- product validators
- product evidence artifacts
- route heuristics
- operator wording tied to one product
- domain-specific governance

These stay downstream unless they can be proven generic.

## Upstream Decision Rules

Promote a lesson to this repository only if all statements are true:

1. The lesson changes peer turn semantics, schema, validation, or prompt rules.
2. The rule does not depend on one product's folder layout, UI, or domain terms.
3. The rule can be explained without Unity, card-game, or one repo's operator
   surface.
4. Both `en/` and `ko/` can carry the same behavior except for language-only
   wording.

If any statement fails, keep it in the downstream product repo or in
`autopilot-template`.

## Compact Evidence Rule

Live use showed that full logs are expensive and fragile as a control surface.
Downstream repos should prefer compact evidence artifacts, but this repository
should only standardize them when the evidence is about DAD runtime truth, such
as:

- packet validator results
- handoff prompt artifact presence/absence rules
- closeout-kind consistency
- backlog admission decisions

It should not standardize product-only dashboard fields or product route labels.

## Sync Checklist For Maintainers

When you update shared DAD behavior here:

1. update the affected root contracts if the first-read workflow changed
2. update both variants under `en/` and `ko/`
3. update prompts, hooks, tools, and skills together when the behavior crosses
   those boundaries
4. run `tools/Validate-TemplateVariants.ps1 -RunVariantValidators`
5. verify the change still reads as a thin-root system, not a monolith

## Common Misplacements

Belongs in `autopilot-template`:

- wake/reschedule watchdogs
- operator decision PR workflow
- manager dashboard refresh rules
- compact status signal conventions
- bounded wait / timeout behavior

Belongs here:

- packet schema invariants
- handoff and closeout rules
- validator-first discovery rules
- peer prompt loading order
- downstream session artifact requirements

Belongs only downstream:

- product governance language
- Unity MCP evidence wording
- product route buckets
- domain-specific dashboards
- product-specific doctor checks

## Integration Outcome

The intended interaction is:

1. `autopilot-template` decides when and how to run
2. this template defines what a valid DAD session turn means
3. the product repo supplies the domain task, evidence, and operator surface

## Real-Usage Lessons Relevant To This Layer

Observed in live downstream use (2026-04, Unity card-game + peer-relay runtimes):

- **Template is read-only at runtime.** Downstream loops must not read or write
  inside the copied template's source repo. Validators should refuse to walk
  out of the target repo root. If a downstream keeps reaching back into
  `dad-v2-system-template/`, that is drift — the variant should be re-copied
  once and then treated as local.
- **Non-ASCII contract docs need explicit encoding discipline.** `PROJECT-RULES.md`,
  `CLAUDE.md`, `AGENTS.md`, `DIALOGUE-PROTOCOL.md`, `Document/DAD/*.md`, and
  `.prompts/*.md` must be UTF-8 **with** BOM when they contain Korean or other
  non-ASCII prose. Skill frontmatter files (`.agents/skills/**/SKILL.md`,
  `agents/openai.yaml`) must stay UTF-8 **without** BOM because loaders expect
  YAML at byte 0. `tools/Validate-Documents.ps1` should enforce both sides of
  this split; a silent BOM drop produces agent-visible mojibake that then
  propagates into code identifiers and UI labels.
- **Split thin-root contracts before they grow.** When a frequently-read root
  contract approaches the large-doc threshold, split by topic into
  `Document/DAD/*.md` rather than relying on chunked-read fallback. Enforce
  the threshold at pre-commit for root contracts too, not only variant docs.
- **Peer symmetry is a schema invariant, not a style rule.** If a downstream
  introduces a `RelaySide` enum, a role-conditional cost-advisor branch, or an
  audit-only framing for one peer, that is drift from this template's core
  contract. Validators should reject packet shapes that encode "which side" as
  anything other than a swappable string identifier.
- **Downstream validators drifted smaller, not larger.** The
  `en/tools/Validate-DadPacket.ps1` and `ko/tools/Validate-DadPacket.ps1`
  here are ~780 lines each. Both DAD-v2 peer relays
  (`D:\codex-claude-relay`, `D:\cardgame-dad-relay`) ship
  `tools/Validate-Dad-Packet.ps1` at 242 lines — missing `Test-AnyRegex`,
  `Get-PacketFiles`, `Parse-PacketMetadata`, `Get-CheckpointDescriptions`,
  `Test-RequiresDisconfirmation`, `Get-SessionPackets`, and
  `Validate-StateObject`. Relay-generated packets are therefore validated
  per-file only; session-wide invariants (peer-review disconfirmation,
  state.json shape, packet sequencing) are never checked by the relay's
  own tooling. A packet the relay validator accepts can still be rejected
  by the template validator — quiet contract drift for anything consuming
  relay output. Next time a downstream copies the validator, copy in full
  or have the downstream's smoke target invoke this template's validator
  against a staged sample.
- **Status enums need paired reason strings at the schema level.** `PACKET-SCHEMA.md` already pairs `suggest_done` with a required `done_reason`. Downstream relays later retrofitted `loop_reason` onto their compact manager signals (cardgame-dad-relay #13) after operators repeatedly needed to dig through logs to find WHY a non-default state was in effect. Generalize the existing `done_reason` discipline: any status/state enum in a DAD-v2 packet or relay signal (proposed/accepted/amended, aligned/amended/superseded, blocked, waiting) should ship a paired `<status>_reason` string in the same payload — always present, default empty, populated whenever the status is non-default. Consuming UIs should refuse to render a non-default status without the reason.
- **Repo identity belongs on every machine-readable output surface.** cardgame-dad-relay merged five back-to-back PRs (#7-#11) each propagating `repo_identity` through one more surface (admission+runbook, startup output, terminal writeback, post-completion visibility, manager status). Identity was declared once in an IMMUTABLE block but no schema contract required every output surface to carry it; serial retrofit was O(surfaces). Protocol-level fix: any DAD-v2 packet or relay state block that can be published, forwarded, or reviewed across repo boundaries should include a `repo_identity` fingerprint (repo name + remote origin hash + expected branch) as a required schema field, matching the IMMUTABLE declaration. Validators should reject packets whose identity disagrees with the live runtime.

Each item above passed the upstream decision rules (peer-semantic or schema,
product-neutral, expressible equally in `en/` and `ko/`). Product-specific
flavors (Unity MCP wording, card-game dashboards, relay-specific doctor
commands) stay downstream.
