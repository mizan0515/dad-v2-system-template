# Validator-First, Discovery-Deferred

현재 DAD v2의 우선순위가 왜 discovery 자동화가 아니라 closeout enforcement 강화인지, 무엇을 채택했고 무엇을 보류했으며, 어떤 조건이 충족돼야 `/discover`를 다시 검토할 수 있는지는 이 파일을 기준으로 본다.

## 1. 왜 지금 validator 보강이 우선인가

DAD v2는 세 가지 ownership 규칙을 전제한다.

- session은 execution을 소유한다
- `handoff.next_task`는 current-session continuation을 소유한다
- `Document/dialogue/backlog.json`은 future session admission을 소유한다

이번 조정 전까지, "`handoff.next_task`는 current-session continuation 용이며, 다른 session이 필요한 작업은 backlog로 보낸다"는 규칙은 `PACKET-SCHEMA.md`에 명시돼 있었지만 packet validator가 강제하지 않았다. `handoff.closeout_kind: final_no_handoff`로 세션을 닫으면서도 비어 있지 않은 `handoff.next_task`를 남길 수 있었고, 이는 "closing session"의 의미론과 모순되는 orphan continuation pointer를 만들어 냈다.

이는 기능 부족이 아니라 enforcement gap이었다. 시스템은 under-featured가 아니라 under-enforced였다.

## 2. `final_no_handoff` + `handoff.next_task` 규칙

현재 규칙은 `tools/Validate-DadPacket.ps1`가 강제하고 `PACKET-SCHEMA.md`에 기록돼 있다.

- `handoff.closeout_kind: final_no_handoff`인 closeout packet은 `handoff.next_task`를 비워 둬야 한다.
- 닫히는 세션에는 continuation이 없다. 남은 follow-up 작업은 세션 봉인 전에 `Document/dialogue/backlog.json`으로 admit해야 한다.
- Validator 수준: error.

warning이 아니라 error로 결정한 근거:

- 기존 `final_no_handoff` 구조 체크(`ready_for_peer_verification: false`, 빈 `prompt_artifact`)가 이미 error다. 같은 규칙 집합 안에서 severity를 통일해야 규칙이 일관된다.
- warning이면 orphan 패턴이 조용히 지속되면서 이 규칙이 닫으려 한 바로 그 gap이 다시 열린다.
- 이 template source repository에는 live packet이 없어 소급 파괴가 없다. 이 템플릿을 복사한 downstream 저장소는 일회성 마이그레이션(`next_task` 비우기 또는 backlog admit)으로 대응하며, 이는 bounded cost이지 반복 비용이 아니다.

### 기존 downstream packet 마이그레이션 메모

downstream 저장소에 이미 `final_no_handoff`인데 비어 있지 않은 `handoff.next_task` packet이 있다면 아래 둘 중 하나로 고친다.

1. 내용이 stale continuation marker에 불과하면 `handoff.next_task`를 비우고 세션 closeout은 그대로 둔다.
2. 실제 follow-up 작업이 남아 있다면 먼저 대응되는 backlog item을 만들거나 재사용한 뒤, packet을 다시 검증하기 전에 `handoff.next_task`를 비운다.

텍스트를 남겨 둔 채 로컬 관례로 덮어쓰지 않는다. 닫히는 세션에는 continuation pointer가 없다.

## 3. `handoff.next_task`는 discovery source가 아니라 closeout enforcement 대상이다

이전 iteration에서 `handoff.next_task`를 discovery 신호로 쓰자는 제안이 있었다. 그 접근은 기각한다.

- `handoff.next_task`는 closeout contract의 일부이지, 상시 backlog가 아니다.
- `handoff.next_task`를 스캔해 반영 안 된 follow-up을 찾는다는 구조는 session ownership 밖에서 또 다른 execution log를 만드는 것과 같다.
- 올바른 경로는 enforcement다. continuation이 필요하면 `peer_handoff`로 이어지는 세션의 `handoff.next_task`에 있고, 현재 세션에 속하지 않는다면 backlog item이 된다. 제3의 저장소는 없다.

## 4. `/discover`는 왜 보류되었나

저장소 follow-up 후보를 스캔하는 수동 `/discover` slash command는 여러 번 검토되었으나, 현재 결정은 보류다.

이유:

- validator ERROR, `open_risks`, `handoff.next_task`를 모두 제외하면 (이것들은 모두 enforcement 영역) 남는 입력 신호가 매우 좁다.
  - commit baseline 이후 새로 추가된 `TODO` / `FIXME` / `HACK` 마커
  - 구조화된 `blocked` backlog item의 blocker 해소 여부 (단 `blocked_by`가 구조화된 경우에만. 현재는 자유 텍스트라 사실상 비활성)
- 이 신호들은 기존 shell 도구(`git log`, `grep`, `jq`)로 회수 가능하다. 새 slash command가 enable 조건이 아니다.
- Claude Code 공식 문서로 capability 부족이 원인이 아님이 확인된다.
  - custom command와 skill 모두 shell preprocessing, arguments, local file access를 지원한다 ([code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills), 2026-04-16 확인).
  - Cloud Routine은 fresh clone에서 실행되며 local file access가 없다 ([code.claude.com/docs/en/desktop-scheduled-tasks](https://code.claude.com/docs/en/desktop-scheduled-tasks), 2026-04-16 확인). 따라서 자동화된 변형은 설계 차원에서 배제된다.
- Section 2의 closeout enforcement가 "놓친 follow-up" 문제의 가장 흔한 형태(orphan continuation)를 코드 수준에서 차단한다.

## 5. 보류된 `/discover` 최소 설계 (미래 참조용)

`/discover`를 다시 연다면 아래 제약이 적용된다.

- 수동 slash command만. 스케줄링, cron, routine 기반 자동 호출 금지.
- local-only. 웹 검색, 외부 조회, 텔레메트리 금지.
- 별도 discovery-candidates.json staging registry를 만들지 않는다. 기존 `Document/dialogue/backlog.json`만 사용한다.
- 선택적 backlog provenance 필드: `source: "user" | "session" | "discovery"`. `tools/Validate-DadBacklog.ps1`의 "미지정 필드 무시" 성질만으로는 안전하지 않다. 같은 작업 패키지 안에서 validator가 허용 집합을 강제하도록 확장해야 한다.
- discovery는 `next` 또는 `later`만 생성할 수 있다. `now`, `promoted`, `done`, `dropped`, `blocked`는 생성할 수 없다.
- active session이 있을 때 discovery는 실행되지 않는다. `BACKLOG-AND-ADMISSION.md`의 admission 규칙이 그대로 적용된다.
- direct promotion 금지. promotion은 오직 세션 생성 시점에 일어난다.
- 허용 입력 source:
  - commit baseline 이후 새로 추가된 `TODO` / `FIXME` / `HACK` 마커
  - 구조화된 `blocked` backlog item의 unblock 상태 (`blocked_by`가 구조화된 경우에만)
- 명시적 제외:
  - validator ERROR (enforcement 영역)
  - `open_risks` (session evidence 영역)
  - `handoff.next_task` (closeout enforcement 영역)
  - wording correction, summary/state sync, closure seal, validator-noise cleanup, 기타 모든 meta-only ceremony

## 6. 채택 / 보류 / 기각

채택:

- `tools/Validate-DadPacket.ps1` error 체크: `final_no_handoff` + 비어 있지 않은 `handoff.next_task`는 invalid (en/ko 대칭).
- `PACKET-SCHEMA.md` 규칙 문장 강화 (en/ko 대칭).
- `.prompts/03-턴-종료-핸드오프-정리.md`에서 `final_no_handoff`에 대한 "저장소 별도 관례" 탈출구 제거 (en/ko 대칭).
- `VALIDATION-AND-PROMPTS.md`에 새 rule 참조와 이 설계 문서 링크 추가 (en/ko 대칭).

보류:

- `/discover` 수동 slash command.
- `tools/Manage-DadBacklog.ps1`의 `-Source` 파라미터와 `tools/Validate-DadBacklog.ps1`의 `source` 필드 강제 (`/discover`를 다시 열 때만 필요).
- `final_no_handoff`에 대한 `handoff.context` leak warning (운영 데이터상 continuation pointer가 `context`로 새어 들어오는 사례가 관측될 때만 유의미).

기각:

- Cloud Routine 기반 discovery. [code.claude.com/docs/en/desktop-scheduled-tasks](https://code.claude.com/docs/en/desktop-scheduled-tasks) 기준 cloud routine은 fresh clone에서 실행되어 local file access가 없다.
- Desktop Scheduled Task 기반 자동 discovery. 기술적으로 가능하지만 "수동 전용, 자동 호출 금지" 요건에 위배된다.
- 별도 discovery-candidates.json staging registry. backlog 책임을 중복시키고 session ownership 바깥에 parallel execution log를 다시 만든다.

## 7. `/discover` 재검토 조건

`/discover`는 아래 조건이 **모두** 충족될 때에만 다시 연다.

1. `blocked_by`가 구조화된 스키마(id reference 또는 URL)로 마이그레이션되어, "blocker resolution"이 자유 텍스트 매칭이 아니라 validatable signal이 된다.
2. Section 2 closeout enforcement가 적어도 한 릴리스 주기 동안 적용된 이후에도 orphan follow-up 사건이 enforcement만으로 설명되지 않는 비율로 지속된다.
3. `/discover`가 만들 수 있는 concrete artifact 또는 verified decision 클래스가 스캔 리포트 이상으로 식별된다. `BACKLOG-AND-ADMISSION.md` 기준으로 스캔 리포트 단독은 session outcome으로 admit되지 않는다.
4. en/ko parity 비용과 `tools/Validate-DadBacklog.ps1` 확장(`source` 필드 강제) 비용이 `/discover` 도입 작업 패키지 안에서 함께 예산화된다.

위 조건 중 하나라도 충족되지 않으면 `/discover`를 다시 열지 않는다.
