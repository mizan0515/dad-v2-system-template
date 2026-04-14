# 공통 프로젝트 규칙

이 파일은 이 저장소에서 모든 에이전트가 함께 따르는 공통 규칙 레이어다.

템플릿을 실제 프로젝트에 쓰기 전에, 아래 플레이스홀더를 반드시 그 프로젝트의 실제 사실로 바꿔야 한다.

## Source Of Truth

문서가 서로 충돌할 때 어떤 순서로 우선할지 이 섹션에 적는다. 예시는 다음과 같다.

1. Core gameplay / product spec
2. Development plan
3. UI / UX spec
4. Feature-specific design notes

추가 기대사항:

- 오래된 요약이나 채팅 메모보다 live 파일을 우선한다.
- 우선순위가 낮은 문서는 상위 canonical term을 다시 정의하면 안 된다.
- stale summary를 발견하면 가능하면 같은 작업에서 같이 갱신한다.

## Current Repository Reality

오래된 요약, migration 메모, archive prompt를 신뢰하기 전에 이 저장소의 현재 현실을 채워 넣는다. 최소한 아래를 명시한다.

- 이미 존재하는 모듈/디렉터리와 아직 계획 상태인 항목
- 지금 시점의 authoritative state / service / file
- 코드보다 뒤처질 가능성이 큰 오래된 요약이나 운영 메모
- 코드 리뷰나 handoff에서 혼동되기 쉬운 용어
- 현재 저장소에서 실제로 요구되는 tool/runtime 전제

문서와 live 저장소가 충돌하면 live 저장소를 우선하고, 가능하면 같은 작업에서 stale 문서를 갱신한다.

## Project Facts

에이전트가 절대 추측하면 안 되는 사실을 채워 넣는다. 예시는 다음과 같다.

- Genre / product type
- Current milestone
- Main architecture boundaries
- Ownership of authoritative runtime state
- Critical terminology that must not be confused

## Guardrails

모든 에이전트가 반드시 지켜야 하는 하드 규칙을 적는다. 예시는 다음과 같다.

- What must remain data-driven
- Which services own authoritative state
- Which terms must stay distinct
- Shared-vs-local ownership rules
- Randomness / seed rules
- UI / runtime / transport separation rules
- Documentation update expectations

## Verification Expectations

이 저장소에서 요구하는 최소 검증 기준을 적는다. 예시는 다음과 같다.

- Narrowest useful test first
- Focused lint / test / smoke before broad suite
- How to report blocked verification
- What counts as sufficient evidence

## DAD Operating Reality

이 저장소가 DAD v2를 채택한다면, 아래 같은 운영 현실을 별도로 명시한다.

- 하나의 긴 umbrella session보다 짧은 session-scoped slice를 선호하는지
- 언제 현재 세션을 닫고 새 세션으로 supersede할지
- `suggest_done: true` 전에 어떤 validator가 필수인지
- summary, work-session note, research/inventory 문서를 어떻게 같이 갱신할지
- 첫 세션 전에 어떤 bootstrap / environment 점검이 필요한지

## Git Rules

이 저장소의 git 정책을 적는다. 예시는 다음과 같다.

- Work on a task branch, not `main`
- Commit and push after meaningful verified changes
- Report clearly when unrelated dirty files block staging
