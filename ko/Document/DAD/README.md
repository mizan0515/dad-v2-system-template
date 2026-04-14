# DAD 상세 참조 문서

상세 DAD 프로토콜 규칙은 하나의 거대한 루트 계약 문서에 몰아넣지 않고 여기 둔다.

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
- `VALIDATION-AND-PROMPTS.md`
