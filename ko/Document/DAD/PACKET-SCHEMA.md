# DAD 패킷 스키마

Turn Packet 전체 형식과 필드 규칙은 이 파일을 기준으로 본다.

## Turn Packet 형식

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

## 필드 규칙

- `my_work`는 필수다.
- `suggest_done`, `done_reason`는 `handoff` 안에만 둔다.
- `handoff.ready_for_peer_verification: true`면 `handoff.prompt_artifact`가 필요하며, 해당 턴의 peer prompt artifact를 가리켜야 한다.
- `handoff.ready_for_peer_verification: true`면 `handoff.next_task`, `handoff.context`도 둘 다 비어 있지 않아야 한다.
- `suggest_done: true`면 `done_reason`이 필요하다.
- 최종 converged no-handoff 턴에서는 `suggest_done: true`와 `ready_for_peer_verification: false` 조합을 사용할 수 있다.
- `suggest_done: true`이면서 `ready_for_peer_verification: false`인 턴에서는 `prompt_artifact`를 비워 둔다.
- 닫힌 세션에는 summary artifact가 필요하다.
- `self_work`, 루트 레벨 `suggest_done` 같은 별칭/오염 필드는 허용하지 않는다.
