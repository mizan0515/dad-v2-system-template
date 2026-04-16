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
  closeout_kind: ""              # peer_handoff | final_no_handoff | recovery_resume
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
- 새 packet에서는 `handoff.closeout_kind`를 채우는 편이 맞다. 허용 값은 `peer_handoff`, `final_no_handoff`, `recovery_resume`이다.
- `peer_handoff`는 다음 peer 턴이 남았다는 뜻이다. `handoff.ready_for_peer_verification: true`, 비어 있지 않은 `handoff.next_task`, 비어 있지 않은 `handoff.context`, 유효한 `handoff.prompt_artifact`가 필요하다.
- `peer_handoff`는 outcome 작업을 넘길 때 사용한다. wording correction, summary/state sync, closure seal, validator-noise cleanup 같은 ceremony-only 정리만을 넘기기 위해 쓰지 않는다. DAD 시스템 자체를 복구하는 경우만 예외다.
- `final_no_handoff`는 새 peer prompt 없이 이번 턴에서 세션을 닫는다는 뜻이다. `handoff.ready_for_peer_verification: false`, 빈 `handoff.prompt_artifact`, 빈 `handoff.next_task`가 필요하다. 닫히는 세션에는 continuation이 없다. 남은 follow-up 작업이 있으면 세션을 봉인하기 전에 backlog로 admit한다.
- `recovery_resume`는 인터럽트나 context overflow 때문에 peer prompt 없이 같은 에이전트가 나중에 이어받아야 한다는 뜻이다. `handoff.ready_for_peer_verification: false`, `suggest_done: false`, 빈 `handoff.prompt_artifact`, `my_work.confidence: low`, 그리고 resume blocker를 설명하는 `open_risks` 항목이 최소 1개 필요하다.
- `handoff.ready_for_peer_verification: true`면 `handoff.prompt_artifact`가 필요하며, 해당 턴의 peer prompt artifact를 가리켜야 한다.
- `handoff.ready_for_peer_verification: true`면 `handoff.next_task`, `handoff.context`도 둘 다 비어 있지 않아야 한다.
- `handoff.ready_for_peer_verification: true`라면 `handoff.next_task`는 여전히 concrete remaining work를 가리켜야 한다. dedicated verify-only handoff는 remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, provenance/compliance-sensitive 작업일 때만 허용되는 risk-gated 예외다.
- `handoff.next_task`는 current session continuation을 위한 것이다. 다른 session이 필요한 작업으로 바뀌면 backlog admission으로 넘기는 편이 맞다.
- 세션 종료, block, supersede를 기록하는 closeout packet이라면 linked backlog item이 stale `promoted`로 남아 있으면 안 된다. 같은 closeout 경로에서 함께 resolve하거나 재큐잉한다.
- `suggest_done: true`면 `done_reason`이 필요하다.
- 최종 converged no-handoff 턴에서는 `suggest_done: true`와 `ready_for_peer_verification: false` 조합을 사용할 수 있다.
- `suggest_done: true`이면서 `ready_for_peer_verification: false`인 턴에서는 `prompt_artifact`를 비워 둔다.
- `handoff.closeout_kind`가 없는 legacy packet은 validator가 `peer_handoff` 또는 `final_no_handoff`를 모호하지 않게 추론할 수 있을 때만 허용한다. handoff prompt도 없고 final closeout 표식도 없는 active non-final 턴은 invalid다.
- 닫힌 세션에는 summary artifact가 필요하다.
- `self_work`, 루트 레벨 `suggest_done` 같은 별칭/오염 필드는 허용하지 않는다.
