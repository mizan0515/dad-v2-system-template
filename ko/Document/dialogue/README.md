# Dialogue 세션 레이아웃

`Document/dialogue/`는 live DAD v2 세션 산출물을 보관한다.

아직 초기 설정 단계라면 첫 실제 세션을 만들기 직전까지는 이 폴더를 깊게 읽지 않아도 된다.

템플릿은 의도적으로 live 세션 데이터를 포함하지 않는다. `tools/New-DadSession.ps1`로 첫 세션을 만든 뒤부터 이 폴더가 중요해진다.

## 먼저 봐야 할 핵심

- `state.json`은 현재 활성 세션 하나만 추적한다
- `sessions/{session-id}/`는 그 세션의 durable artifact를 보관한다
- 각 턴에는 `turn-{N}.yaml`과 짝이 맞는 `turn-{N}-handoff.md`가 모두 필요하다

## 예상 구조

- `state.json`
- `sessions/{session-id}/state.json`
- `sessions/{session-id}/turn-{N}.yaml`
- `sessions/{session-id}/turn-{N}-handoff.md`
- `sessions/{session-id}/summary.md`
- 종료된 세션의 경우 `sessions/{session-id}/YYYY-MM-DD-{session-id}-summary.md`

## 규칙

- 템플릿에 가짜 세션을 미리 심어두지 않는다.
- 첫 세션은 `tools/New-DadSession.ps1`로 생성한다.
- 각 신규 턴 파일은 `tools/New-DadTurn.ps1`로 생성한다.
- 각 턴에서 실제로 출력한 peer prompt를 `sessions/{session-id}/turn-{N}-handoff.md`에 저장하고, 그 경로를 `handoff.prompt_artifact`에 기록한다.
- 짧은 session-scoped slice를 기본으로 삼고, 목표나 검증 표면이 크게 바뀌면 하나의 세션을 억지로 늘리지 말고 새 세션을 연다.
- 새 세션이 현재 세션을 대체하면 이전 세션을 명시적으로 close 또는 supersede하고 summary 산출물을 유지한다.
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`는 live 세션이 없는 동안 skip 메시지를 출력하며, 첫 세션 생성 이후부터 필수가 된다.
- 패킷 수정 이후와 세션을 done으로 표시하기 전에 `tools/Validate-DadPacket.ps1 -Root . -AllSessions`를 실행한다.
