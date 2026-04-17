# .autopilot/STATE.md — live state, keep ≤60 lines. Loaded every iteration.

root: prototypes/relay-app-mvp
base: main
iteration: 0
status: initialized
active_task: null
# active_task schema:
#   slug: <kebab-case>
#   plan: [bullet, bullet]
#   started_iter: N
#   branch: dev/autopilot-relay-<slug>-<YYYYMMDD>
#   gate: G<n>  (reference to .autopilot/MVP-GATES.md)

plan_docs:
  - prototypes/relay-app-mvp/DEV-PROGRESS.md
  - prototypes/relay-app-mvp/IMPROVEMENT-PLAN.md
  - prototypes/relay-app-mvp/README.md

spec_docs:
  - prototypes/relay-app-mvp/PHASE-A-SPEC.md
  - prototypes/relay-app-mvp/INTERACTIVE-REBUILD-PLAN.md
  - prototypes/relay-app-mvp/TESTING-CHECKLIST.md
  - prototypes/relay-app-mvp/CLAUDE-APPROVAL-DECISION.md
  - prototypes/relay-app-mvp/capability-matrix.md

reference_docs:
  - PROJECT-RULES.md
  - CLAUDE.md
  - AGENTS.md
  - DIALOGUE-PROTOCOL.md

# Auto-merge refuses if the PR diff touches any of these:
protected_paths:
  - prototypes/relay-app-mvp/RelayApp.sln
  - prototypes/relay-app-mvp/.autopilot/PROMPT.md
  - prototypes/relay-app-mvp/.autopilot/hooks/
  - prototypes/relay-app-mvp/.autopilot/project.ps1
  - prototypes/relay-app-mvp/.autopilot/project.sh
  - prototypes/relay-app-mvp/.autopilot/MVP-GATES.md
  - prototypes/relay-app-mvp/.autopilot/CLEANUP-LOG.md
  - prototypes/relay-app-mvp/.autopilot/CLEANUP-CANDIDATES.md
  - PROJECT-RULES.md
  - CLAUDE.md
  - AGENTS.md
  - DIALOGUE-PROTOCOL.md
  - .githooks/
  - en/
  - ko/
  - tools/

open_questions:
  - "Does the rotation-with-carry-forward exercise (F-live-1) meaningfully preserve Goal/Completed/Pending across the split, or do the fields end up empty in practice?"
  - "Can the approval UI communicate destructive-tier risk without operator reading the full command, or is the risk summary still too abstract?"
  - "Is Claude's audit-only stance still the right call given the handoff-parser maturity curve, or should we revisit per CLAUDE-APPROVAL-DECISION.md?"

# MVP gates: canonical checklist at .autopilot/MVP-GATES.md. STATE tracks only tally.
mvp_gates: 0/8
mvp_last_advanced_iter: 0

# OPERATOR overrides — any line starting with `OPERATOR:` wins over PROMPT.md.
#   OPERATOR: halt
#   OPERATOR: halt evolution
#   OPERATOR: focus on <task>
#   OPERATOR: allow evolution <rationale>
#   OPERATOR: allow push to main for <task>    (single use, delete after use)
#   OPERATOR: require human review             (disables auto-merge globally)
#   OPERATOR: run cleanup                      (promotes Cleanup mode this iter; one-shot)
#   OPERATOR: mvp-rescope <rationale>          (allow gate count to decrease; one-shot)
#   OPERATOR: post-mvp <direction>             (unblocks after mvp-complete halt; sticky)
#   OPERATOR: approve cleanup <candidate-date> (authorizes Phase B bulk-delete; one-shot)
#
# One-shot overrides are CONSUMED by the loop at the end of the iteration that
# acts on them — the exit step deletes the line from this file. Sticky
# overrides persist until the operator removes them manually.
