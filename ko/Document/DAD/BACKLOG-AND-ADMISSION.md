# DAD 백로그와 세션 승격

이 문서는 backlog 범위, admission rule, session linkage 규칙을 설명한다.

## 목적

`Document/dialogue/backlog.json`은 future session candidate를 관리하는 얇은 admission layer다.

이 파일은 아래가 아니다.

- 실행 로그
- peer handoff 버퍼
- packet, state, summary의 대체물

## 역할 분리

- 현재 실행 진실은 session artifact가 가진다.
- 현재 세션 안의 continuation은 `handoff.next_task`가 가진다.
- 미래 세션 후보는 `Document/dialogue/backlog.json`이 가진다.

이 역할이 겹치기 시작하면 backlog가 너무 무거워진 것이다.

## 파일과 정책

Backlog 파일: `Document/dialogue/backlog.json`

기본 skeleton:

```json
{
  "schema_version": "dad-v2-backlog",
  "policy": {
    "max_now_items": 1,
    "allow_active_session_without_backlog_link": false
  },
  "items": []
}
```

## Item 의미

각 backlog item은 turn plan이 아니라 candidate session outcome이다.

최소 필드:

- `id`
- `title`
- `status`
- `workstream`
- `desired_outcome`
- `session_warrant`
- `acceptance_signal`
- `risk_class`
- `recommended_scope`

도움이 되는 추적 필드:

- `active_session_id`
- `closed_by_session_id`
- `derived_from_ids`
- `blocked_by`
- `why_not_now`
- `evidence_refs`
- `session_history`

## 허용 상태

- `now`: active session이 없을 때 바로 다음 세션 후보
- `next`: 근시일 후보지만 아직 admission 전
- `later`: 가치가 있으나 의도적으로 뒤로 미룸
- `blocked`: 외부 blocker나 누락 조건 때문에 대기
- `promoted`: 현재 active session과 연결됨
- `done`: 세션 outcome으로 닫힘
- `dropped`: 의도적으로 pursue하지 않음

## Admission 규칙

- 새 non-recovery session은 정확히 하나의 backlog item과 연결되어야 한다.
- `tools/New-DadSession.ps1`는 재사용할 `now` candidate가 없고 사용자가 완전히 fresh task로 시작할 때만 backlog item을 auto-bootstrap할 수 있다.
- active session이 있으면 별도의 `now` item을 두지 않는다.
- active session이 이미 있으면 새로 드러난 future work는 바로 승격하지 말고 `next`, `later`, `blocked` 중 하나로 남긴다.
- active session이 없으면 `now` item은 최대 1개만 둔다.
- 이미 `now` item이 있으면 중복 fresh item을 auto-bootstrap하지 말고 그 item을 재사용하거나 우선순위를 다시 정한다.
- 이미 queued 또는 promoted item으로 표현된 작업이라면 sibling candidate를 auto-bootstrap하지 않는다. 재사용, reprioritize, explicit split 중 하나로 처리한다.
- 승격은 peer handoff를 쓸 때가 아니라 session을 만들 때 일어난다.
- `dad-system-repair` 자체가 concrete outcome인 경우가 아니면 backlog grooming이나 우선순위 논의만을 위한 별도 session 또는 peer debate를 열지 않는다.
- backlog priority는 user-facing admission metadata이지, 명시적 사용자 의도를 덮어쓰는 autonomous scheduler가 아니다.

## Handoff와의 경계

아래는 `handoff.next_task`로 처리한다.

- 같은 session 안에 남는 작업
- 같은 outcome의 다음 slice

아래는 backlog로 보낸다.

- 다른 session이 필요한 작업
- 현재 session에서 out-of-scope가 된 작업
- blocker 때문에 나중에 다시 들어와야 하는 작업
- 별도 artifact나 verified decision이 필요한 작업

짧은 규칙:

- 같은 session => `handoff.next_task`
- 다른 session => backlog

## 제품 작업과 시스템 복구

허용 `workstream` 값:

- `product`
- `dad-system-repair`

문서/validator/prompt 복구 자체가 1차 outcome이 될 수 있는 경우는 `dad-system-repair`뿐이다.

`product` backlog item에는 다음 같은 ceremony-only 작업을 넣지 않는다.

- wording correction
- summary/state sync
- closure seal
- validator-noise cleanup
- verify-only ritual

## Closeout 규칙

- `recovery_resume`는 backlog promotion event가 아니다.
- 세션을 `active`에서 다른 상태로 바꾸는 같은 closeout 안에서 linked backlog item도 함께 resolve하거나 의도적으로 재큐잉해야 한다. 세션 closeout 뒤에 dangling `promoted` item을 남기지 않는다.
- 세션이 수렴하면 일반적으로 연결된 backlog item도 `done`으로 닫는다.
- 세션 abandon은 backlog item을 `blocked`, `next`, `dropped` 중 하나로 남길 수 있다.
- 세션 supersede는 backlog item drop을 자동으로 뜻하지 않는다.
- `promoted`가 아닌 item은 `active_session_id`를 비워야 한다. terminal `done` item은 `closed_by_session_id`를 기록해야 한다.
- 같은 outcome을 후속 세션이 계속 가져간다면 기존 linked item을 재사용하거나 의도적으로 split한다. session id가 바뀌었다는 이유만으로 unrelated sibling item을 새로 부트스트랩하지 않는다.

## Canonical Truth

Backlog 상태는 reconstructible metadata다.

실제 canonical execution evidence는 session packet, session state, session summary가 유지한다.
