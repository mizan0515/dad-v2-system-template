# DAD 검증과 프롬프트 참조

validator 실행 시점, peer prompt 규칙, prompt reference는 이 파일을 기준으로 본다.

## Peer Prompt 규칙

다음 peer 턴이 남아 있을 때, 모든 peer prompt는 아래를 포함해야 한다.

1. `Read PROJECT-RULES.md first. Then read {agent-contract}.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. 구체적인 `handoff.next_task + handoff.context`
5. relay-friendly summary
6. mandatory tail block
7. `handoff.prompt_artifact`에 저장된 동일한 프롬프트 본문. 기본 경로는 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`

같은 종료 응답 안에도 그 동일한 프롬프트 본문이 들어가야 한다. `user-bridged` 모드에서는 artifact만 저장해 두고 사용자가 따로 "다음 프롬프트"를 요청하게 만들면 안 된다.

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
- `tools/Validate-CodexSkillMetadata.ps1 -Root .`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`
- `tools/Validate-DadBacklog.ps1 -Root .`

최소 실행 시점:

1. turn packet 저장 직후
2. 해당 턴이 실제로 peer handoff를 내보내는 경우, `handoff.prompt_artifact`가 가리키는 handoff prompt artifact 저장 직후
3. `suggest_done: true`를 기록하기 직전
4. 복구 세션을 재개하기 직전
5. backlog linkage가 바뀌었거나 linked session을 닫기 직전
6. `.agents/skills/*/SKILL.md`나 `agents/openai.yaml`을 수정한 직후

최종 converged no-handoff 턴에서는 `handoff.prompt_artifact`를 비워 둘 수 있고 `handoff.ready_for_peer_verification`도 false일 수 있다. 다만 `suggest_done: true`이면 validator는 여전히 `handoff.done_reason`을 요구한다.

non-final 턴에서 `handoff.prompt_artifact`와 `handoff.ready_for_peer_verification`를 모두 비워 두는 것은 명시적인 `handoff.closeout_kind: recovery_resume` packet일 때만 허용된다.

validator를 통과했다고 해서 meta-only 후속 턴이 정당화되지는 않는다. wording correction, summary/state sync, closure seal, validator-noise cleanup은 DAD 시스템 자체를 복구하는 경우가 아니면 현재 execution turn 안에서 끝내야 한다.

다음 peer 턴이 남아 있으면 `handoff.next_task`도 여전히 outcome 작업을 가리켜야 한다. dedicated verify-only relay는 remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, provenance/compliance-sensitive 작업일 때만 정당화된다.

`Validate-DadPacket.ps1`는 risk-gated 이유 없이 `peer_handoff`가 meta-only 정리처럼 읽히면 warning을 낼 수 있다. 이런 warning은 새 relay 턴을 열기보다 현재 execution turn 안으로 다시 접거나, 실제 위험 근거를 더 구체적으로 쓰라는 신호로 보면 된다.

`Validate-DadPacket.ps1`는 또한 `final_no_handoff` packet이 `handoff.next_task`를 비워 두도록 강제한다. 닫히는 세션에는 continuation이 없다. 남은 follow-up 작업은 같은 closeout 경로에서 backlog로 admit해야 한다. 정확한 규칙은 `PACKET-SCHEMA.md`, 배경 설계 근거는 `VALIDATOR-FIRST-DISCOVERY-DEFERRED.md`를 본다.

업그레이드한 downstream 저장소에 예전 `final_no_handoff` packet이 아직 `handoff.next_task`를 채운 채 남아 있다면, stale 텍스트는 비우고 실제 follow-up 작업이 남아 있을 때만 backlog로 admit한 뒤 `handoff.next_task`를 비운다.

`Validate-DadBacklog.ps1`는 execution log가 아니라 admission layer를 검사한다. active session마다 `promoted` item이 정확히 하나만 있는지, active session이 있을 때 별도 `now` item이 남지 않는지를 강하게 본다.

`Validate-CodexSkillMetadata.ps1`는 UTF-8 without BOM으로 유지해야 하는 runtime `SKILL.md`와 `agents/openai.yaml`이 ASCII-safe인지도 함께 본다.

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

최종 converged 턴, 특히 더 이상 peer prompt가 남지 않는 턴에서는 `.prompts/06-수렴-종료-PR-정리.md`를 사용한다. 이 프롬프트는 summary/state 산출물뿐 아니라 필요한 git closeout까지 확인하는 체크리스트다.

- 필요한 참조 문서가 한 번에 읽기엔 너무 크면, 먼저 section index를 보고 필요한 부분만 chunk 단위로 읽는다.
- monolithic read가 한 번 실패했다고 작업을 중단하지 않는다.
- fallback 문구를 계속 늘리기보다, 큰 참조 문서는 미리 분할하는 쪽을 우선한다.
