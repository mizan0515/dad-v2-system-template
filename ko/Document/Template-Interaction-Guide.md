# 템플릿 상호작용 가이드

## 왜 이 문서가 필요한가

실사용 저장소는 보통 3계층으로 굴러간다:

1. 바깥 자동 루프/운영자 제어
2. DAD 런타임/세션 계약
3. downstream 제품 런타임과 운영 정책

이 템플릿은 그중 2계층만 책임진다.

## lesson learned를 어느 계층에 둘 것인가

`autopilot-template`에 둘 것:

- compact status surface
- decision-PR 운영자 제어
- bounded wait / wake 규칙
- stale-signal 체크
- generic doctor 체크

이 DAD 템플릿에 둘 것:

- packet/state 스키마 규칙
- handoff / closeout semantics
- validator 동작
- prompt artifact 요구사항
- backlog / session admission 규칙

downstream 제품 저장소에 남길 것:

- 제품 전용 dashboards
- 제품 전용 prompts
- 도메인 evidence wording
- 제품 route heuristics
- 도메인 governance wording

## 실제 저장소 적용 순서

1. 바깥 루프가 필요하면 `autopilot-template`를 먼저 복사한다
2. 이 저장소의 한 변형을 복사한다
3. 루트 계약 문서를 실제 저장소 기준으로 바꾼다
4. outer loop wrapper에서 compact status artifact를 정의한다
5. 제품 전용 dashboard/evidence는 제품 저장소에 남긴다

## upstream 이동 전 점검

실사용 lesson을 이 템플릿으로 올리기 전에 아래를 묻는다:

1. 재사용 가능한 DAD 동작을 바꾸는가?
2. 한 제품 도메인 없이 설명 가능한가?
3. `en/`, `ko/`에 대칭적으로 실을 수 있는가?

셋 중 하나라도 아니면 이 템플릿 소속이 아니다.
