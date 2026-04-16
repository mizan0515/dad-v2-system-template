# 11. DAD 운영 감사

## 목적

실제 세션이 쌓인 뒤에도 DAD v2 시스템이 저장소의 **live 운영 현실**과 계속 맞물려 있는지 점검한다.

이 프롬프트는 규칙 문서가 맞는지만 보지 않는다. prompt, command, skill, validator, session artifact가 현재 저장소의 실제 사용 방식과 여전히 맞는지까지 같이 감사한다.

## 언제 사용하나

아래 중 하나라도 해당하면 이 프롬프트를 기본 감사 프롬프트로 포함한다.

1. DAD 시스템 파일을 최근에 둘 이상 수정했을 때
2. live 세션이 이미 있고 handoff 품질, premature PASS, validator blind spot, prompt drift가 의심될 때
3. prompt pack이 현재 저장소 구조나 운영 습관보다 낡아 보일 때
4. 새 담당자나 새 모델이 DAD 시스템을 이어받기 직전일 때
5. 제품 기능과 별개로 "지금 DAD 시스템 자체가 운영상 건강한가"를 점검해야 할 때

## 감사 범위

최소한 아래를 함께 본다.

- `AGENTS.md`
- `CLAUDE.md`
- `DIALOGUE-PROTOCOL.md`
- 루트 프로토콜이 얇게 유지되는 구조라면 `Document/DAD/README.md`와 그 상세 참조 문서
- `.prompts/README.md`와 관련 `.prompts/*.md`
- `.claude/commands/`
- `.agents/skills/`
- `Document/DAD 운영 가이드.md`
- `Document/dialogue/state.json`
- `Document/dialogue/sessions/`
- `tools/Validate-DadPacket.ps1`
- `tools/Validate-Documents.ps1`

## 기본 감사 항목

1. 루트 계약 문서가 같은 운영 규칙을 말하는가
   - session 경로, Turn Packet 스키마, `suggest_done` gate, auto-converge, main 직접 push 금지, 필수 꼬리말
2. prompt / command / skill이 현재 프로토콜과 실제 호출 흐름에 맞는가
   - dead reference, 빠진 파일, 낡은 용어, 잘못된 저장 경로
3. prompt pack이 현재 저장소 운영에 맞게 충분히 분화되어 있는가
   - 빠진 운영 프롬프트가 없는가
   - 반대로 과해졌거나 이미 낡은 프롬프트가 남아 있지 않은가
4. 운영 가이드와 live artifact가 일치하는가
   - `state.json`, 최신 `turn-{N}.yaml`, summary, 세션 디렉터리 구조
5. validator가 실제 문제를 잡아내는가
   - validator blind spot도 감사 대상에 포함한다
   - validator 통과만으로 시스템이 건강하다고 가정하지 않는다
6. 현재 저장소에 추가 운영 제약이 필요한가
   - 작업 크기 규범
   - user-bridged 비용 관리
   - 반복 실패 패턴
   - 첫 clone / 첫 session bootstrap 위험
   - outcome-scoped session gate를 명시해야 하는지
   - peer verification allowlist가 필요한지
   - wording-only / sync-only / seal-only 턴을 막는 anti-churn 규칙이 필요한지
7. 최근 세션 기록이 실제 outcome 작업 중심인지, 아니면 meta-only churn인지
   - wording correction, summary/state sync, closure seal, validator-noise cleanup만을 위해 열린 세션이 있는지
   - 명확한 risk trigger 없이 반복된 peer-verify-only 턴이 있는지
   - 제품 artifact, measurement, fix, decision보다 ceremony에 더 많은 턴을 쓰는 세션 체인이 있는지

## 실행 규칙

1. 서술형 요약보다 live 파일과 live session artifact를 우선한다.
2. validator 결과는 참고 자료로 보되, validator 자체도 감사 대상에 포함한다.
3. 실제 FAIL을 찾으면 가능하면 같은 턴에서 직접 수정하고 diff를 남긴다.
4. 같은 턴에 닫지 못하는 gap은 첫 번째 후속 작업으로 명시한다.
5. "좋아 보인다" 같은 인상평은 금지하고, 모든 판정은 파일/라인 또는 artifact 근거로만 적는다.
6. 필요한 파일이 한 번에 읽기엔 너무 크면, 필요한 section만 chunk 단위로 읽고 감사를 계속 진행한다.
7. meta-only 세션 체인을 generic process-health 판정 안에 숨기지 말고 별도 위험으로 명시한다.

## 출력 형식

각 항목은 아래 라벨을 사용한다.

- `PASS`: 현재 규칙과 live artifact가 맞는다. 파일/라인 또는 artifact 근거 포함
- `FAIL`: 현재값, 기대값, 운영상 영향, 수정 diff 포함
- `WARN`: 즉시 위반은 아니지만 drift 위험이 누적 중이다. 왜 지금 보강해야 하는지와 권장 후속 작업 포함

## 권장 동반 참조

- 시스템 drift를 직접 수정할 때는 `10-시스템-문서-정합성-동기화.md`를 함께 사용한다
- validator와 session 구조 신뢰성을 볼 때는 live `Document/dialogue/` artifact와 최근 summary를 같이 읽는다
- 운영 모델 자체를 재평가할 때는 프로토콜 문서만 보지 말고, 대상 저장소가 work-session note나 chat-log artifact를 보유한다면 그 최근 기록도 표본으로 읽는다
