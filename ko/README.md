# DAD v2 시스템 템플릿

Codex와 Claude Code가 대칭 턴으로 협업하는 Dual-Agent Dialogue v2 워크플로우의 재사용 가능한 스타터 템플릿.

협업 구성 요소:

- `AGENTS.md`
- `CLAUDE.md`
- `DIALOGUE-PROTOCOL.md`
- `.claude/commands/`
- `.agents/skills/`
- `.prompts/`
- `tools/`
- `Document/dialogue/`

## 이 템플릿을 어디에 쓰는가

이 템플릿은 Codex와 Claude Code가 대화 로그에만 의존하지 않고, 세션과 턴 기록을 남기면서 규칙적으로 협업하도록 저장소를 세팅할 때 사용한다.

실제 프로젝트에 넣으면 다음 역할을 한다:

- 두 에이전트가 먼저 읽는 루트 계약 문서를 제공한다
- `Document/dialogue/` 아래에 세션과 턴 기록 구조를 만든다
- 문서, 패킷, 스킬 메타데이터 drift를 잡는 validator를 제공한다
- 자주 쓰는 DAD 흐름용 프롬프트, 명령, 스킬을 함께 제공한다

이 저장소 자체는 live 프로젝트가 아니라 스타터다. 보통의 사용 순서는 다음과 같다:

1. 템플릿을 실제 저장소 루트에 복사한다.
2. 플레이스홀더를 그 저장소의 실제 규칙으로 바꾼다.
3. Codex 스킬을 등록한다.
4. 세션을 열고 턴을 기록하면서 운영한다.

## 처음에는 이것만 읽으면 된다

처음 쓰는 사람은 파일을 전부 먼저 읽으려고 하지 않는 편이 낫다.

다음 순서로 읽으면 된다:

1. 이 `README.md`
2. `PROJECT-RULES.md`
3. `AGENTS.md`, `CLAUDE.md`
4. `DIALOGUE-PROTOCOL.md`
5. 프로토콜이 필요하다고 가리킬 때만 `Document/DAD/`

처음 성공 경로만 빠르게 밟고 싶다면 핵심 순서는 이렇다:

1. `PROJECT-RULES.md`를 채운다
2. 문서 validator를 돌린다
3. 저장소 전용 스킬 namespace를 설정한다
4. Codex 스킬 메타데이터를 검증한다
5. Codex Desktop 스킬을 등록한다
6. 첫 세션과 첫 턴을 만든다

## 포함 항목

- Codex와 Claude Code용 루트 계약 문서
- 공유 project-rules 템플릿
- DAD v2 프로토콜
- 세션 시작 / 반복 워크플로우용 슬래시 명령 문서
- 동일한 흐름을 위한 스킬 문서
- 세션 / 부트스트랩 validator
- 감사, 세션 시작, 핸드오프, 복구, 디베이트, 수렴 종료, 마이그레이션, 템플릿 검토, 비상 복구, 시스템 문서 동기화, live 운영 감사를 위한 핵심 프롬프트 세트

## 런타임 요구사항

- Windows: `powershell` 5.1 또는 `pwsh` 7.2+
- macOS / Linux / Git Bash: `pwsh` 7.2+ 필수
- `tools/*.sh`의 크로스플랫폼 래퍼 스크립트가 `pwsh`(Windows 셸에서는 `powershell`)를 통해 대응 `.ps1` 파일을 호출한다
- 아래 명령 예시는 `pwsh` 기준이다. Windows PowerShell 5.1에서는 `pwsh -File`을 `powershell -ExecutionPolicy Bypass -File`로 교체한다.

## 권장 설정 순서

처음 이 템플릿을 쓰는 경우에는 아래 순서대로 진행하는 편이 가장 안전하다.

### 1. 실제 저장소에 템플릿을 복사한다

이 변형의 내용을 대상 저장소 루트에 복사한다. `.agents`, `.claude`, `.githooks`, `.prompts` 같은 숨김 폴더도 빠지지 않게 옮긴다.

### 2. 플레이스홀더 저장소 규칙을 실제 규칙으로 바꾼다

가장 먼저 `PROJECT-RULES.md`부터 바꾼다. 이 파일은 템플릿 설명이 아니라 대상 저장소의 실제 운영 현실을 설명해야 한다.

다음 내용을 실제 프로젝트 기준으로 교체한다:

- 그 저장소에서 무엇이 source of truth인지
- 어떤 빌드, 테스트, 배포 guardrail이 있는지
- converged DAD 세션의 최종 git/PR closeout 정책이 무엇인지
- 에이전트가 반드시 지켜야 하는 운영 제약이 무엇인지

그 다음 `AGENTS.md`, `CLAUDE.md`, `DIALOGUE-PROTOCOL.md`를 검토해서 프로젝트 정책상 달라져야 하는 부분만 조정한다.

### 3. 실제로 필요한 프롬프트 팩을 확인한다

처음부터 모든 프롬프트를 다 쓸 필요는 없다. 가장 자주 쓰는 진입점은 다음과 같다:

- 기존 저장소에 DAD v2를 넣을 때 `.prompts/07-기존-프로젝트-도입-마이그레이션.md`
- 템플릿 구성 자체를 검토하고 강화할 때 `.prompts/08-템플릿-검토-개선.md`
- 세션 상태나 validator 흐름을 수동 복구해야 할 때 `.prompts/09-비상-세션-복구.md`
- 실제 운영이 쌓인 뒤 시스템 동작을 감사할 때 `.prompts/11-DAD-운영-감사.md`

### 4. 계약 문서를 수정한 뒤 문서 검증을 돌린다

루트 계약 문서를 조정했다면 문서 validator를 한 번 실행한다:

```powershell
pwsh -File tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix
```

이 명령은 문서 포맷을 정리하고 필요한 BOM 정책을 맞춘다.

단, 예외적으로 `.agents/skills/*/SKILL.md`와 `agents/openai.yaml`은 YAML/frontmatter가 byte 0에서 바로 시작해야 하므로 UTF-8 without BOM을 유지해야 한다. 실무적으로는 Windows no-BOM mojibake를 피하기 위해 두 런타임 파일 모두 ASCII-safe로 유지하는 편이 안전하다.

### 5. 저장소 전용 Codex 스킬 namespace를 설정한다

스킬 등록 전에 예약된 템플릿 namespace를 바꿔야 한다:

```powershell
pwsh -File tools/Set-CodexSkillNamespace.ps1 -Namespace "your-project-prefix"
```

이 단계가 중요한 이유:

- 템플릿은 예약 namespace `dadtpl-`로 배포된다
- live 저장소가 이 공용 prefix를 그대로 쓰면 안 된다
- 스킬 폴더명, frontmatter `name:`, 데스크톱 등록 이름이 모두 같은 namespace로 맞아야 한다

`acg-`처럼 짧고 안정적인 저장소 전용 prefix를 쓰는 편이 좋다.

### 6. Codex 스킬 메타데이터를 검증한다

```powershell
pwsh -File tools/Validate-CodexSkillMetadata.ps1 -Root .
```

등록 전이나 샘플 훅 활성화 전에 이 검증을 먼저 돌린다. namespace 불일치, 런타임 스킬 파일의 BOM 문제, OpenAI 메타데이터 형식 문제를 초기에 잡는 용도다.

### 7. Codex Desktop 스킬을 등록한다

```powershell
pwsh -File tools/Register-CodexSkills.ps1
```

이 단계는 자주 빠뜨리기 쉽다. Codex Desktop는 저장소 안의 `.agents/skills/`를 자동 발견하지 않는다.

등록 과정에서 다음을 수행한다:

- 먼저 스킬 메타데이터를 검증한다
- 스킬을 `$CODEX_HOME` 아래 `skills` 디렉터리에 링크한다
- 더 이상 존재하지 않는 저장소를 가리키는 stale registration을 정리한다

템플릿 namespace `dadtpl-`가 그대로 남아 있으면 등록은 진행되지 않는다. 등록이 끝나면 Codex Desktop를 재시작한다.

스킬 런타임 파일은 아래 조건을 엄격히 지켜야 한다:

- `.agents/skills/*/SKILL.md`는 UTF-8 without BOM이어야 하고 byte 0에서 `---`가 시작해야 한다
- `.agents/skills/*/SKILL.md`는 no-BOM 경로이므로 localized prose 대신 ASCII-safe 본문을 유지하는 편이 안전하다
- `.agents/skills/*/agents/openai.yaml`은 UTF-8 without BOM, 단일 YAML 문서, ASCII-safe display metadata를 유지해야 한다

### 8. 필요하면 프로젝트 전용 프롬프트를 추가한다

기본 프롬프트 세트로 부족하면 `.prompts/` 아래에 프로젝트 전용 프롬프트를 추가한다. 대신 자주 읽히는 루트 문서는 얇게 유지하고, 상세 운영 규칙은 `Document/` 아래의 별도 문서로 빼는 편이 낫다.

### 9. 첫 세션을 생성한다

```powershell
pwsh -File tools/New-DadSession.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -TaskSummary "Describe the task" `
  -Scope medium `
  -Mode hybrid
```

이 명령은 `Document/dialogue/` 아래에 세션 골격을 만들고, `Document/dialogue/backlog.json`의 backlog item 하나를 세션에 연결한다. 아직 맞는 item이 없으면 task summary를 바탕으로 자동 생성한다. 세션 ID는 사람이 읽기 쉬우면서도 안정적인 이름으로 정한다.

이 auto-bootstrap 경로는 fresh work에만 쓰는 편이 맞다. 재사용 가능한 `now` item이 이미 있으면 같은 outcome용 sibling backlog item을 새로 만들지 말고 기존 candidate를 승격한다.

### 10. 첫 턴을 생성한다

```powershell
pwsh -File tools/New-DadTurn.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -Turn 1 `
  -From codex
```

실제 에이전트 발화가 오갈 때마다 턴 파일을 하나씩 만든다. 가능하면 패킷 파일을 손으로 처음부터 쓰지 말고, 생성 스크립트가 만든 스켈레톤을 바탕으로 채운다.

### 11. 실제 핸드오프 프롬프트를 그대로 남긴다

peer에게 작업을 넘기는 턴을 마무리할 때마다 다음을 지킨다:

- 실제로 상대 에이전트에게 넘긴 handoff prompt를 `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`에 저장한다
- 그 경로를 `handoff.prompt_artifact`에 기록한다
- 같은 본문을 그 턴을 닫는 같은 최종 응답에도 그대로 남긴다

상태 요약만 남기고 사용자가 "다음 프롬프트 달라"고 다시 요청하게 만들면 안 된다. `user-bridged` 모드에서 relay prompt는 현재 턴 산출물의 일부다.

현재 턴이 최종 converged closeout이라 새 peer prompt가 없다면, handoff artifact를 억지로 만들지 말고 summary/state 산출물과 `PROJECT-RULES.md`가 요구하는 git closeout을 마무리한다.

이렇게 해야 나중에 세션 기록을 감사할 수 있고, 다음 에이전트가 실제 전달 문맥을 재현할 수 있다.

## 일상 운영 흐름

저장소 적응이 끝난 뒤에는 보통 아래 흐름으로 운영한다:

1. 하나의 명확하고 outcome-scoped인 목표에 대해 하나의 세션을 열거나 이어간다.
2. 발화 주체가 바뀔 때마다 새 턴 파일을 만든다.
3. 각 에이전트는 현재 패킷과 계약 문서를 기준으로 작업한다.
4. 현재 세션 안의 다음 작업은 `handoff.next_task`에 두고, 다른 세션이 필요한 후속 작업만 `Document/dialogue/backlog.json`에 기록한다.
5. 다음 에이전트에게 넘긴 실제 핸드오프 프롬프트를 저장한다.
6. 세션을 끝내기 전에 패킷 validator를 돌린다.

각 세션은 코드 diff, 측정 artifact, smoke 결과, config/runtime 결정, 명시적 risk disposition 같은 구체적 결과를 하나 이상 남겨야 한다.

세션이 종료되거나 supersede되거나 blocked로 빠질 때는 같은 closeout 경로에서 linked backlog item도 함께 갱신한다. active가 아닌 세션의 backlog item을 `promoted`로 남겨 두면 안 된다.

wording correction, summary/state sync, closure seal, validator-noise cleanup만을 위해 새 세션을 열지 않는다. DAD 시스템 자체의 recovery나 schema/packet repair가 아닌 한 그런 작업은 현재 execution session 안에서 처리한다.

peer-verify-only 턴은 현재 변경이 remote-visible, config/runtime-sensitive, measurement-sensitive, destructive, provenance/compliance-sensitive할 때만 사용한다.

패킷 수정 이후와 세션 종료 전에는 다음 검증을 실행한다:

```powershell
pwsh -File tools/Validate-DadPacket.ps1 -Root . -AllSessions
pwsh -File tools/Validate-DadBacklog.ps1 -Root .
```

`Validate-DadPacket.ps1`는 첫 live 세션이 생기기 전까지는 skip 메시지를 출력한다. 하지만 첫 세션이 만들어진 뒤에는 선택 사항이 아니라 일상 운영 절차의 일부로 보는 편이 맞다.

`Validate-DadBacklog.ps1`는 admission layer와 active-session linkage를 검증한다. packet validator는 `peer_handoff`가 ceremony-only 정리처럼 읽히면 warning을 낼 수도 있다. 이 warning은 hard fail이 아니라 triage 신호이며, 실제 risk-gated verification 단계가 없다면 해당 작업을 현재 execution turn 안에서 끝내라는 뜻에 가깝다.

세션은 짧은 session-scoped slice를 기본으로 잡는다. 작업 의미가 크게 바뀌면 하나의 세션을 억지로 늘리지 말고, 새 세션을 만들고 이전 세션을 명시적으로 close 또는 supersede한다.

## 파일 크기 설계 규칙

- 루트 계약 문서와 자주 읽히는 프롬프트 문서는 에이전트 도구가 한 번에 읽을 수 있을 정도로 얇게 유지한다.
- 상세 프로토콜 표, lifecycle 규칙, validation reference는 `Document/DAD/` 아래의 주제별 파일로 분리한다.
- 참조 문서가 다시 커지면 또 주제별로 나누고, 하나의 거대한 Markdown 파일로 키우지 않는다.
- 이렇게 해야 에이전트가 필수 파일을 먼저 읽는 과정에서 `file content exceeds maximum allowed tokens` 같은 실패를 줄일 수 있다.

## Bash 래퍼

`bash` / `sh`를 선호하는 셸에서는 각 PowerShell 스크립트 옆의 래퍼를 사용한다:

```bash
./tools/Validate-Documents.sh -IncludeRootGuides -IncludeAgentDocs -Fix
./tools/Set-CodexSkillNamespace.sh -Namespace "your-project-prefix"
./tools/Validate-CodexSkillMetadata.sh -Root .
./tools/Register-CodexSkills.sh
./tools/New-DadSession.sh -SessionId "YYYY-MM-DD-your-task" -TaskSummary "Describe the task"
```

## Pre-commit 훅

샘플 훅: `.githooks/pre-commit`

복제한 저장소에서 활성화하려면:

```bash
git config core.hooksPath .githooks
```

샘플 훅이 실행하는 명령:

- `tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -ReportLargeDocs -ReportLargeRootGuides -FailOnLargeDocs`
- `tools/Validate-CodexSkillMetadata.ps1 -Root .`
- `tools/Register-CodexSkills.ps1 -Root . -CodexHome .git/.codex-hook-validate -ValidateOnly`
- `tools/Lint-StaleTerms.ps1`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`
- `tools/Validate-DadBacklog.ps1 -Root .`

이 훅의 registration dry-run은 예약된 템플릿 namespace `dadtpl-`가 그대로 남아 있으면 의도적으로 실패한다. downstream 저장소에서는 훅을 켜기 전에 `tools/Set-CodexSkillNamespace.ps1 -Namespace "<repo-prefix>"`를 먼저 적용해야 한다.

## 자주 하는 실수

- 템플릿 저장소 자체를 live 세션 작업공간처럼 쓰지 않는다.
- 복사 후에도 `PROJECT-RULES.md`를 플레이스홀더 상태로 두지 않는다.
- 스킬 등록 전에 namespace 교체를 빼먹지 않는다.
- 등록 전에 메타데이터 검증을 생략하지 않는다.
- Codex Desktop가 `.agents/skills/`를 자동 발견할 것이라고 가정하지 않는다.
- 템플릿에 가짜 dialogue 세션을 미리 심지 않는다.
- 실제로 peer에게 작업을 넘기는 턴의 handoff prompt 산출물을 저장하는 절차를 빼먹지 않는다.
- active non-final 턴을 실제 peer handoff나 명시적 `recovery_resume` packet 없이 끝내지 않는다.
- `converged` 상태만 기록하고 git closeout이 끝났다고 가정하지 않는다. 최종 턴 PR 정책을 `PROJECT-RULES.md`에 명시하고 `.prompts/06-수렴-종료-PR-정리.md`로 강제한다.
- wording 수정, state/summary 동기화, closure seal, validator 잡음 제거만을 위한 새 세션을 열지 않는다. broken DAD state를 복구하는 예외가 아니면 현재 execution session 안에서 같이 끝낸다.
- peer verification을 의식처럼 반복하지 않는다. verify-only 턴은 remote-visible, 되돌리기 어려움, config/runtime-sensitive, measurement-sensitive, provenance/compliance-sensitive 작업일 때만 쓴다.

## 참고 사항

- 템플릿에는 기본적으로 live 세션이 포함되어 있지 않다.
- `Document/dialogue/`는 구조 placeholder를 제외하고 의도적으로 비어 있다.
- `Document/dialogue/backlog.json`은 future session candidate를 위한 얇은 admission registry이며, execution log가 아니다.
- 첫 live 세션이 생성되기 전까지 `Validate-DadPacket.ps1`는 skip 메시지를 출력한다.
- `Document/dialogue/README.md`는 예상 세션 레이아웃과 summary 산출물을 문서화한다.
- Codex Desktop는 `$CODEX_HOME` 아래 `skills` 디렉터리의 설치된 스킬만 읽고, 등록 스크립트를 실행하기 전에는 저장소의 `.agents/skills/`를 자동 인덱싱하지 않는다.
- 핵심 DAD 스킬은 하나의 저장소 전용 namespace prefix를 유지해야 한다. 폴더명, 각 스킬 frontmatter의 `name:` 필드, 전역 등록 이름은 `tools/Set-CodexSkillNamespace.ps1`로 함께 맞춘다.
