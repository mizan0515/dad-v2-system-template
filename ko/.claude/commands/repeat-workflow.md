---
description: Dual-Agent Dialogue v2 대칭 턴 반복 실행
argument-hint: "[턴 수, 기본 5]"
---

# /repeat-workflow

Dual-Agent Dialogue v2 프로토콜에 따라 대칭 턴 기반 협업 세션을 반복 실행한다.

## 인자

- `$ARGUMENTS` = 반복 턴 수 (1~10). 비어 있으면 5.

## 절차

1. `PROJECT-RULES.md`를 먼저 읽고, 그다음 `CLAUDE.md`와 `DIALOGUE-PROTOCOL.md`를 읽어 v2 프로토콜을 숙지한다.
2. `Document/dialogue/state.json`에서 기존 세션 상태를 확인한다 (없으면 `/dialogue-start`로 새 세션을 시작).
3. 현재 프로젝트 상태를 분석한다.
4. 각 턴마다:
   a. **상대 작업 피드백**: Contract 체크포인트 기준 PASS/FAIL
   b. **자기 계획 + 실행**: 자체 반복 루프 수행
   c. **Turn Packet 저장**: `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
   d. **남은 작업 판별**: 남은 작업이 wording correction, state/summary sync, closure seal, validator-noise cleanup뿐이면 DAD 시스템 자체를 복구하는 경우가 아닌 한 현재 execution turn 안에서 끝낸다.
   e. **현재 세션 연장과 미래 세션 후보 분리**: 현재 세션 안에서 이어지는 작업만 `handoff.next_task`에 둔다. 새로 드러난 다른 future session 작업은 현재 handoff를 늘리지 말고 `Document/dialogue/backlog.json`에 기록한다.
      이번 closeout이 세션 종료, block, supersede로 이어지면 linked backlog item도 같은 경로에서 resolve하거나 재큐잉해서 stale `promoted` owner를 남기지 않는다.
   f. **상대용 프롬프트 artifact 저장**: 일반 relay라면 `handoff.closeout_kind: peer_handoff`를 설정하고, 정확한 프롬프트 본문을 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`에 저장한 뒤 그 경로를 `handoff.prompt_artifact`에 기록한다. `handoff.ready_for_peer_verification`는 `handoff.next_task`, `handoff.context`, `handoff.prompt_artifact`가 확정되기 전까지 false로 둔다.
      dedicated verify-only handoff는 remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, provenance/compliance-sensitive 작업일 때만 사용한다.
   g. **상대용 프롬프트 생성**: 같은 프롬프트 본문을 그 턴을 닫는 같은 최종 응답에서 사용자에게 출력한다 (CLI 래퍼 불포함). "다음 프롬프트" 재요청을 기다리지 않는다.
      프롬프트에는 반드시 아래 7개 요소를 포함한다:
      - `Read PROJECT-RULES.md first. Then read AGENTS.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
      - `Session: Document/dialogue/state.json`
      - `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
      - 구체적 작업 지시 (`handoff.next_task + handoff.context`)
      - 10줄 안팎의 relay-friendly 요약
      - 아래 필수 꼬리말 블록
      - `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`에 저장한 동일한 본문
      프롬프트 끝에 반드시 아래 꼬리말을 포함한다:
      ```
      ---
      허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
      수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
      중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
      ```
   h. **사용자가 Codex 결과 공유**: 피드백 → 다음 턴
   i. **수렴 판단**: 모든 체크포인트 PASS + 양쪽 done → 세션 closeout을 완료한다. 다음 peer 턴이 남아 있으면 handoff를 출력하고, 이번 턴이 최종 converged 턴이면 `handoff.closeout_kind: final_no_handoff`를 설정한 뒤 같은 턴에서 summary/state 정리와 작업 브랜치 commit + push + PR까지 끝내거나 정확한 blocker를 보고한다. `recovery_resume`는 인터럽트나 context overflow일 때만 사용한다.
5. 종료 시 세션 요약을 `Document/dialogue/sessions/{session-id}/`에 기록한다.

## 안전 가드

1. 하드 턴 제한: `$ARGUMENTS` 초과 시 중단
2. 2턴 연속 품질 정체 → 사용자 ESCALATE
3. 3턴 연속 같은 체크포인트 FAIL → 자동 중단
4. 컴파일 에러 → 먼저 해결 후 진행
5. main 브랜치 직접 push 금지

## 사용자 개입 지점

- 각 턴 전: 방향 수정 가능
- Codex 결과 공유 시: 추가 피드백 가능 (`사용자 메모:`)
- ESCALATE 시: 사용자가 결정

## 호출 예시

```
/repeat-workflow 5
/repeat-workflow 3
/repeat-workflow
```
