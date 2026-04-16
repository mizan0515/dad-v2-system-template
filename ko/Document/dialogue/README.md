# Dialogue 세션 레이아웃

`Document/dialogue/`는 live DAD v2 세션 산출물을 보관한다.

아직 초기 설정 단계라면 첫 실제 세션을 만들기 직전까지는 이 폴더를 깊게 읽지 않아도 된다.

템플릿은 의도적으로 live 세션 데이터를 포함하지 않는다. `tools/New-DadSession.ps1`로 첫 세션을 만든 뒤부터 이 폴더가 중요해진다.

## 먼저 봐야 할 핵심

- `state.json`은 현재 활성 세션 하나만 추적한다
- `backlog.json`은 현재 실행이 아니라 future session candidate를 추적한다
- `sessions/{session-id}/`는 그 세션의 durable artifact를 보관한다
- 각 턴에는 `turn-{N}.yaml`이 필요하고, 실제로 peer handoff를 내보내는 턴에는 짝이 맞는 `turn-{N}-handoff.md`도 필요하다

## 예상 구조

- `state.json`
- `backlog.json`
- `sessions/{session-id}/state.json`
- `sessions/{session-id}/turn-{N}.yaml`
- peer handoff를 내보내는 턴의 `sessions/{session-id}/turn-{N}-handoff.md`
- `sessions/{session-id}/summary.md`
- 종료된 세션의 경우 `sessions/{session-id}/YYYY-MM-DD-{session-id}-summary.md`

## 규칙

- 템플릿에 가짜 세션을 미리 심어두지 않는다.
- outcome-scoped 작업을 위해서만 세션을 열거나 이어간다. 각 세션은 구체적 artifact, 검증된 결정, 또는 명시적 risk disposition을 남겨야 한다.
- backlog item은 turn plan이 아니라 session candidate다. current session continuation은 `handoff.next_task`에 두고, 다른 session이 필요한 작업만 backlog로 보낸다.
- DAD 시스템 자체를 복구하는 예외가 아니면 wording correction, state/summary sync, closure seal, validator-noise cleanup만을 위한 새 세션을 만들지 않는다.
- 새 non-recovery session은 정확히 하나의 backlog item과 연결되어야 한다. `tools/New-DadSession.ps1`는 재사용할 `now` item이 없을 때만 fresh work를 auto-bootstrap할 수 있다.
- 다른 active session이 이미 있으면 unrelated future work를 바로 승격하지 말고 backlog에 대기시킨다. 현재 세션을 닫거나 명시적으로 supersede한 뒤에만 승격한다.
- 우선순위 정리만을 위한 backlog-only session은 열지 않는다. 후보 등록은 정상 closeout 안에서 같이 처리한다.
- peer-verify-only 턴은 현재 변경이 remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, provenance/compliance-sensitive할 때만 사용한다.
- 첫 세션은 `tools/New-DadSession.ps1`로 생성한다.
- 각 신규 턴 파일은 `tools/New-DadTurn.ps1`로 생성한다.
- 실제로 peer handoff를 내보내는 턴마다 출력한 prompt를 `sessions/{session-id}/turn-{N}-handoff.md`에 저장하고, 그 경로를 `handoff.prompt_artifact`에 기록한다.
- 같은 턴을 닫는 최종 응답에도 그 동일한 prompt를 붙인다. 사용자가 별도로 "다음 프롬프트"를 요청할 필요가 없어야 한다.
- 최종 converged 턴은 새 peer prompt 없이 세션을 닫을 수 있다. 이 경우에는 close summary/state 산출물을 남기고 `PROJECT-RULES.md`가 요구하는 git closeout을 마쳐야 한다.
- summary/state sync, closure confirmation, final wording cleanup은 후속 seal 세션이 아니라 같은 closeout 턴 안에서 끝낸다.
- 세션을 종료하거나 supersede하는 같은 closeout 안에서 linked backlog item도 함께 resolve하거나 재큐잉해야 한다. 세션이 더 이상 active가 아닌데 `promoted` item이 남아 있게 두지 않는다.
- 짧은 session-scoped slice를 기본으로 삼고, 목표나 검증 표면이 크게 바뀌면 하나의 세션을 억지로 늘리지 말고 새 세션을 연다.
- 새 세션이 현재 세션을 대체하면 이전 세션을 명시적으로 close 또는 supersede하고 summary 산출물을 유지한다.
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`는 live 세션이 없는 동안 skip 메시지를 출력하며, 첫 세션 생성 이후부터 필수가 된다.
- 패킷 수정 이후와 세션을 done으로 표시하기 전에 `tools/Validate-DadPacket.ps1 -Root . -AllSessions`를 실행한다.
- backlog linkage가 바뀌었거나 linked session을 닫기 전에는 `tools/Validate-DadBacklog.ps1 -Root .`도 실행한다.
