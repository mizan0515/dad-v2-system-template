# Dialogue 세션 레이아웃

`Document/dialogue/`는 live DAD v2 세션 산출물을 보관한다.

## 예상 구조

- `state.json`
- `sessions/{session-id}/state.json`
- `sessions/{session-id}/turn-{N}.yaml`
- `sessions/{session-id}/summary.md`
- 종료된 세션의 경우 `sessions/{session-id}/YYYY-MM-DD-{session-id}-summary.md`

## 규칙

- 템플릿에 가짜 세션을 미리 심어두지 않는다.
- 첫 세션은 `tools/New-DadSession.ps1`로 생성한다.
- 각 신규 턴 파일은 `tools/New-DadTurn.ps1`로 생성한다.
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`는 live 세션이 없는 동안 skip 메시지를 출력하며, 첫 세션 생성 이후부터 필수가 된다.
- 패킷 수정 이후와 세션을 done으로 표시하기 전에 `tools/Validate-DadPacket.ps1 -Root . -AllSessions`를 실행한다.
