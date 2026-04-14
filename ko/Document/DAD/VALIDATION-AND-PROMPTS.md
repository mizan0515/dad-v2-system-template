# DAD 검증과 프롬프트 참조

validator 실행 시점, peer prompt 규칙, prompt reference는 이 파일을 기준으로 본다.

## Peer Prompt 규칙

모든 peer prompt는 아래를 포함해야 한다.

1. `Read PROJECT-RULES.md first. Then read {agent-contract}.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. 구체적인 `handoff.next_task + handoff.context`
5. relay-friendly summary
6. mandatory tail block
7. `handoff.prompt_artifact`에 저장된 동일한 프롬프트 본문. 기본 경로는 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`

Mandatory tail:

```
---
허점이나 개선점이 있으면 직접 수정하고 diff를 보고하라.
수정할 것이 없으면 "변경 불필요, PASS"라고 명시하라.
중요: 관대하게 평가하지 마라. "좋아 보인다" 금지. 구체적 근거와 예시를 들어라.
```

## Validation

사용 명령:

- `tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

최소 실행 시점:

1. turn packet 저장 직후
2. `handoff.prompt_artifact`가 가리키는 handoff prompt artifact 저장 직후
3. `suggest_done: true`를 기록하기 직전
4. 복구 세션을 재개하기 직전

## Prompt References

이 템플릿의 기본 참조 프롬프트:

- `.prompts/01-시스템-감사.md`
- `.prompts/02-세션-시작-컨트랙트-작성.md`
- `.prompts/03-턴-종료-핸드오프-정리.md`
- `.prompts/04-세션-복구-재개.md`
- `.prompts/05-의견차이-디베이트-정리.md`
- `.prompts/06-수렴-종료-PR-정리.md`
- `.prompts/07-기존-프로젝트-도입-마이그레이션.md`
- `.prompts/08-템플릿-검토-개선.md`
- `.prompts/09-비상-세션-복구.md`
- `.prompts/10-시스템-문서-정합성-동기화.md`
- `.prompts/11-DAD-운영-감사.md`

## 큰 파일 읽기 규칙

- 필요한 참조 문서가 한 번에 읽기엔 너무 크면, 먼저 section index를 보고 필요한 부분만 chunk 단위로 읽는다.
- monolithic read가 한 번 실패했다고 작업을 중단하지 않는다.
- fallback 문구를 계속 늘리기보다, 큰 참조 문서는 미리 분할하는 쪽을 우선한다.
