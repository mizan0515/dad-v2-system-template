# DAD 상세 참조 문서

상세 DAD 프로토콜 규칙은 하나의 거대한 루트 계약 문서에 몰아넣지 않고 여기 둔다.

처음 설정할 때 이 폴더의 모든 파일을 다 읽을 필요는 없다.

루트 `DIALOGUE-PROTOCOL.md`만으로 부족할 때만 여기 내려와 상세 규칙을 확인하면 된다.

## 이 폴더를 읽어야 하는 경우

- packet 필드나 필수 산출물이 헷갈릴 때
- 세션 lifecycle이나 종료 상태 규칙이 헷갈릴 때
- backlog admission이나 session 승격 규칙이 헷갈릴 때
- 세션 closeout 때 linked backlog item을 어떻게 정리해야 하는지 헷갈릴 때
- validator 기대사항이나 prompt artifact 규칙을 정확히 확인해야 할 때
- 보류된 기능이나 validator-first 결정의 배경과 재검토 조건을 확인해야 할 때

## 왜 분리하는가

- 에이전트 하네스와 파일 읽기 도구는 큰 Markdown 파일에서 token / file-size limit에 걸릴 수 있다.
- `DIALOGUE-PROTOCOL.md` 같은 루트 계약 문서는 자주 먼저 읽히므로, 한 번에 읽을 수 있는 크기로 유지하는 편이 낫다.
- 스키마 표, validator 체크리스트, prompt reference 목록을 분리하면 drift가 생겨도 파일 단위로 관리하기 쉽다.

## 유지보수 규칙

- 루트 계약 문서는 얇고 authoritative하게 유지한다.
- 상세 스키마, lifecycle, validation 규칙은 `Document/DAD/`의 주제별 문서로 이동한다.
- 이 상세 문서 중 하나가 다시 너무 커지면 또 주제별로 나누고, 다시 monolith로 키우지 않는다.

## 참조 맵

- `PACKET-SCHEMA.md`
- `STATE-AND-LIFECYCLE.md`
- `BACKLOG-AND-ADMISSION.md`
- `VALIDATION-AND-PROMPTS.md`
- `VALIDATOR-FIRST-DISCOVERY-DEFERRED.md`
