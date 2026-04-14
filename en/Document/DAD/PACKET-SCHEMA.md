# DAD Packet Schema

Use this file for the full Turn Packet shape and field rules.

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
  task_model_review:
    status: "aligned | amended | superseded"
    coverage_gaps: []
    scope_creep: []
    risk_followups: []
    amendments: []
  checkpoint_results: {}
  issues_found: []
  fixes_applied: []

my_work:
  task_model: {}
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
  prompt_artifact: ""
  ready_for_peer_verification: false
  suggest_done: false
  done_reason: ""
```

## Field Rules

- `my_work` is mandatory.
- `suggest_done` and `done_reason` live only under `handoff`.
- If `handoff.ready_for_peer_verification: true`, `handoff.prompt_artifact` is required and must point to the saved peer-prompt artifact for that turn.
- If `handoff.ready_for_peer_verification: true`, `handoff.next_task` and `handoff.context` must both be non-empty.
- If `suggest_done: true`, `done_reason` is required.
- Closed sessions require summary artifacts.
- Root-level aliases such as `self_work` or root-level `suggest_done` are invalid.
