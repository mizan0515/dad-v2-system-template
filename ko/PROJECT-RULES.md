# Shared Project Rules

This file is the shared rule layer for all agents in this repository.

Replace the placeholders below with project-specific truth before relying on the template in production.

## Source Of Truth

If documents conflict, define your own priority order here. Example:

1. Core gameplay / product spec
2. Development plan
3. UI / UX spec
4. Feature-specific design notes

Additional expectations:

- Prefer live files over stale summaries or chat notes.
- Lower-priority docs must not redefine higher-priority canonical terms.
- If a stale summary is found, update it in the same task when practical.

## Current Repository Reality

오래된 요약, migration 메모, archive prompt를 신뢰하기 전에 이 저장소의 현재 현실을 채워 넣는다. 최소한 아래를 명시한다.

- 이미 존재하는 모듈/디렉터리와 아직 계획 상태인 항목
- 지금 시점의 authoritative state / service / file
- 코드보다 뒤처질 가능성이 큰 오래된 요약이나 운영 메모
- 코드 리뷰나 handoff에서 혼동되기 쉬운 용어
- 현재 저장소에서 실제로 요구되는 tool/runtime 전제

문서와 live 저장소가 충돌하면 live 저장소를 우선하고, 가능하면 같은 작업에서 stale 문서를 갱신한다.

## Project Facts

Fill in the facts that agents must never guess about, for example:

- Genre / product type
- Current milestone
- Main architecture boundaries
- Ownership of authoritative runtime state
- Critical terminology that must not be confused

## Guardrails

Document the hard rules that every agent must preserve, for example:

- What must remain data-driven
- Which services own authoritative state
- Which terms must stay distinct
- Shared-vs-local ownership rules
- Randomness / seed rules
- UI / runtime / transport separation rules
- Documentation update expectations

## Verification Expectations

Specify the minimum verification standard for this repository, for example:

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

Specify the repository's git policy, for example:

- Work on a task branch, not `main`
- Commit and push after meaningful verified changes
- Report clearly when unrelated dirty files block staging
