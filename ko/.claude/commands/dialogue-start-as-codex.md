---
description: Claude Code와의 Dual-Agent Dialogue v2 세션 시작 (Codex가 Turn 1)
argument-hint: "[작업 설명]"
---

<!-- Role-Swap Mode: Claude Code executes this command but follows the Codex contract (AGENTS.md).
     Use when Codex is unavailable and Claude Code needs to produce a Codex-perspective turn. -->

# /dialogue-start-as-codex

Codex(이 대화창)가 Turn 1을 수행하고 Claude Code용 프롬프트를 생성하는 DAD v2 세션 시작.

## 인자

- `$ARGUMENTS` = 작업 설명 (한 줄). 비어 있으면 프로젝트 상태를 분석하여 자동 제안.

## 전제

- 이 커맨드를 실행하는 에이전트는 **Codex** 역할이다.
- 계약 파일은 `AGENTS.md`이다 (Claude Code는 `CLAUDE.md`).
- 상대(Claude Code)용 프롬프트를 생성할 때 `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`로 시작한다.

## 절차

1. `PROJECT-RULES.md`를 먼저 읽고, 그다음 `AGENTS.md`와 `DIALOGUE-PROTOCOL.md`를 읽어 v2 프로토콜을 숙지한다. `DIALOGUE-PROTOCOL.md`가 `Document/DAD/` 참조를 가리키면 필요한 파일도 같이 읽는다.
2. 현재 프로젝트 상태를 분석한다:
   - `git log --oneline -10` (최근 작업 흐름)
   - `git status` (현재 변경 사항)
   - 최근 실패 테스트, CI 기록, 또는 로컬 검증 로그가 있으면 확인
   - 저장소 전용 research / inventory / architecture 문서가 있으면 확인
3. 제안된 세션이 outcome-scoped인지 먼저 판별한다. wording correction, state/summary sync, closure seal, validator-noise cleanup만의 작업이면 broken DAD state나 packet/schema drift를 명시적으로 복구하는 경우가 아닌 한 현재 execution session 안으로 흡수한다.
4. 작업 scope를 판단한다 (small / medium / large).
5. `Document/dialogue/state.json`이 이미 active session을 가리키면 조용히 두 번째 세션을 열지 않는다. 현재 세션을 이어가거나, 먼저 명시적으로 supersede/repair한 뒤 새 세션으로 넘어간다.
6. `tools/New-DadSession.ps1`로 세션을 생성하고 `Document/dialogue/backlog.json`의 backlog item 하나와 정확히 연결되게 한다. auto-bootstrap은 fresh work이고 재사용할 `now`나 동등한 queued candidate가 없을 때만 허용한다.
7. **Turn 1을 수행한다**:
   a. large scope → `task_model` 작성 (목표/비목표/위험/성공형태)
   b. Sprint Contract 초안 작성 (medium/large일 때):
      - 구체적 체크포인트 목록 (검증 방법 포함)
      - `reference_prompts` 연결
      - 왜 이 세션을 여는지 정당화하는 concrete artifact, 검증된 결정, 또는 risk disposition checkpoint를 최소 1개 포함
   c. 계획 수립 + 실행
   d. 자체 반복 루프: 체크포인트 기준 자체 검증, 만족할 때까지 반복
   e. Turn Packet을 `Document/dialogue/sessions/{session-id}/turn-01.yaml`로 저장
8. `Document/dialogue/state.json` 초기화/업데이트:
   - `protocol_version: "dad-v2"`
   - `relay_mode: "user-bridged"`
   - `last_agent: "codex"` (Turn 1 시작자)
9. 다음 peer 턴이 남아 있더라도 handoff는 outcome 작업일 때만 사용한다. 현재 세션 안에서 이어지는 작업만 `handoff.next_task`에 두고, 새로 드러난 다른 future session 작업은 `Document/dialogue/backlog.json`에 기록한다. 남은 작업이 verify-only / wording-only / sync-only / seal-only 정리라면 risk-gated 예외나 DAD 시스템 복구가 아닌 한 새 handoff를 만들지 않는다.
10. `handoff.closeout_kind: peer_handoff`를 설정하고, 정확한 Claude Code용 프롬프트를 `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`에 저장한 뒤 그 경로를 `handoff.prompt_artifact`에 기록한다. `handoff.ready_for_peer_verification: true`는 `handoff.next_task`, `handoff.context`, `handoff.prompt_artifact`가 모두 확정된 뒤에만 설정한다.
11. 같은 Claude Code용 프롬프트를 Turn 1을 닫는 같은 최종 응답에서 사용자에게 출력한다 (CLI 래퍼 없이 본문만). 상태 요약만 남기고 사용자가 다음 프롬프트를 다시 요청하게 만들지 않는다.
   프롬프트에는 반드시 아래 7개 요소를 포함한다:
   - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
   - `Session: Document/dialogue/state.json`
   - `Previous turn: Document/dialogue/sessions/{session-id}/turn-01.yaml`
   - 구체적 작업 지시 (`handoff.next_task + handoff.context`)
   - 10줄 안팎의 relay-friendly 요약
   - 아래 필수 꼬리말 블록
   - `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`에 저장한 동일한 본문
   프롬프트 끝에 반드시 아래 꼬리말을 포함한다:
   ```
   ---
    허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
    수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
    중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
    ```

## 사용자 선택

세션 모드를 선택할 수 있다:
- **자율**: ESCALATE만 사용자에게. 나머지 자동.
- **감독**: 모든 수렴에 사용자 확인 필요.
- **하이브리드** (기본): large scope 또는 confidence low일 때만 확인.

## 호출 예시

```
/dialogue-start-as-codex 카드 보상 화면 버그 수정
/dialogue-start-as-codex 맵 시스템 코드 감사
/dialogue-start-as-codex
```
