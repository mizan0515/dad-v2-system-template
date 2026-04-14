# Dual-Agent Dialogue Protocol (DAD v2)

Protocol where Codex and Claude Code collaborate through symmetric turns.

## Core Principles

1. Symmetric turns: both agents plan, execute, and evaluate.
2. Sprint Contract: done state is expressed as concrete checkpoints.
3. Self-iteration: each agent verifies its own work before handoff.
4. Live files first: repository reality beats stale memory.
5. Schema discipline: packets and state must validate.
6. System-doc sync: if DAD infra, validators, commands, prompt templates, or agent contracts change, sync the related docs in the same task or make that the first next task.

## Turn Flow

- Turn 1: analyze state, draft contract, execute first slice, self-iterate, write packet, output peer prompt.
- Turn 2+: review the peer turn against checkpoints, execute your own slice, self-iterate, write packet, output peer prompt.

## Turn Packet Shape

```yaml
type: turn
from: [codex | claude-code]
turn: 1
session_id: "YYYY-MM-DD-task"

contract:
  status: "proposed | accepted | amended"
  checkpoints: []
  amendments: []

peer_review:
  project_analysis: "..."        # Turn 1 only (optional on Turn 2+)
  task_model_review:              # Turn 2+ only (optional on Turn 1)
    status: "aligned | amended | superseded"
    coverage_gaps: []
    scope_creep: []
    risk_followups: []
    amendments: []
  checkpoint_results: {}          # always required
  issues_found: []                # always required
  fixes_applied: []               # always required

my_work:
  task_model: {}                  # recommended for large scope; optional otherwise
  plan: ""
  changes:
    files_modified: []
    files_created: []
    summary: ""
  self_iterations: 0
  evidence:
    commands: []
    artifacts: []
  verification: ""
  open_risks: []
  confidence: "high | medium | low"

handoff:
  next_task: ""
  context: ""
  questions: []
  ready_for_peer_verification: true
  suggest_done: false
  done_reason: ""
```

Rules:

- `my_work` is mandatory.
- `suggest_done` and `done_reason` live only under `handoff`.
- If `suggest_done: true`, `done_reason` is required.
- Closed sessions require a summary artifact.

## Shared State

State file: `Document/dialogue/state.json`

Session directory: `Document/dialogue/sessions/{session-id}/`

Root `state.json` tracks the currently active session only. When a new session is created, the root state is overwritten. Previous session state is preserved in `sessions/{session-id}/state.json`.

Expected contents per session directory:

- `turn-{N}.yaml`
- `state.json`
- `summary.md` for session-scoped summary
- `YYYY-MM-DD-{session-id}-summary.md` for named summary on closed sessions

### State Schema

`state.json` (both root and session-scoped) must contain:

| Field | Required | Values |
|-------|----------|--------|
| `protocol_version` | always | `"dad-v2"` |
| `session_id` | always | string |
| `session_status` | always | `active` \| `converged` \| `superseded` \| `abandoned` |
| `relay_mode` | always | `"user-bridged"` |
| `mode` | always | `autonomous` \| `hybrid` \| `supervised` |
| `scope` | always | `small` \| `medium` \| `large` |
| `current_turn` | always | integer (0 before first turn) |
| `max_turns` | always | integer |
| `last_agent` | after first turn | `codex` \| `claude-code` |
| `contract_status` | always | `proposed` \| `accepted` \| `amended` |
| `packets` | always | array of relative paths |
| `closed_reason` | when status != `active` | string |
| `superseded_by` | when status == `superseded` | session-id string |

### Context Overflow

When an agent's context window fills mid-session:

1. Save the current work as a partial turn packet (set `confidence: low` and note the overflow in `open_risks`).
2. Start a fresh context and use `.prompts/04-session-recovery-resume.md` to resume safely.
3. The recovery prompt will re-read state.json and the latest turn packet to restore working context.

## Prompt Generation Rules

Every peer prompt must include:

1. `Read PROJECT-RULES.md first. Then read {agent-contract}.md and DIALOGUE-PROTOCOL.md.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. concrete `handoff.next_task + handoff.context`
5. A ~10-line relay-friendly summary
6. The mandatory tail block

Mandatory tail:

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```

## Validation

Use:

- `tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs -Fix`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

Minimum moments to run validation:

1. after saving a turn packet
2. before recording `suggest_done: true`
3. before resuming a recovered session

## Prompt References

Base references in this template:

- `.prompts/01-system-audit.md`
- `.prompts/02-session-start-contract.md`
- `.prompts/03-turn-closeout-handoff.md`
- `.prompts/04-session-recovery-resume.md`
- `.prompts/05-debate-disagreement.md`
- `.prompts/06-convergence-pr-closeout.md`
- `.prompts/07-existing-project-migration.md`
- `.prompts/08-template-review-hardening.md`
- `.prompts/09-emergency-session-recovery.md`
- `.prompts/10-system-doc-sync.md`
