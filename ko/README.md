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

## 포함 항목

- Codex와 Claude Code용 루트 계약 문서
- 공유 project-rules 템플릿
- DAD v2 프로토콜
- 세션 시작 / 반복 워크플로우용 슬래시 명령 문서
- 동일한 흐름을 위한 스킬 문서
- 세션 / 부트스트랩 validator
- 감사, 세션 시작, 핸드오프, 복구, 디베이트, 수렴 종료, 마이그레이션, 템플릿 검토, 비상 복구, 시스템 문서 동기화를 위한 핵심 프롬프트 세트

## 런타임 요구사항

- Windows: `powershell` 5.1 또는 `pwsh` 7.2+
- macOS / Linux / Git Bash: `pwsh` 7.2+ 필수
- `tools/*.sh`의 크로스플랫폼 래퍼 스크립트가 `pwsh`(Windows 셸에서는 `powershell`)를 통해 대응 `.ps1` 파일을 호출한다
- 아래 명령 예시는 `pwsh` 기준이다. Windows PowerShell 5.1에서는 `pwsh -File`을 `powershell -ExecutionPolicy Bypass -File`로 교체한다.

## 적용 방법

1. `PROJECT-RULES.md`의 플레이스홀더를 대상 저장소의 실제 source-of-truth 및 guardrail로 교체한다.
2. 저장소가 다른 git / 테스트 / 리뷰 정책을 요구하면 `AGENTS.md`와 `CLAUDE.md`를 조정한다.
3. 기존 저장소에 DAD v2를 도입하는 경우 `.prompts/07-기존-프로젝트-도입-마이그레이션.md`를 먼저 읽는다.
4. 템플릿 자체를 검토하고 강화하려면 `.prompts/08-템플릿-검토-개선.md`를 사용한다.
5. 강제 종료, 수동 상태 복구, validator 장애 복구용으로 `.prompts/09-비상-세션-복구.md`를 상시 참조 가능하게 둔다.
6. 루트 계약 문서를 조정한 뒤 문서 검증을 한 번 실행한다:

```powershell
pwsh -File tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs -Fix
```

7. 필요하면 프로젝트별 프롬프트를 `.prompts/`에 추가한다.
8. 첫 세션을 시작한다:

```powershell
pwsh -File tools/New-DadSession.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -TaskSummary "Describe the task" `
  -Scope medium `
  -Mode hybrid
```

9. 첫 턴 스켈레톤을 생성한다:

```powershell
pwsh -File tools/New-DadTurn.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -Turn 1 `
  -From codex
```

## Bash 래퍼

`bash` / `sh`를 선호하는 셸에서는 각 PowerShell 스크립트 옆의 래퍼를 사용한다:

```bash
./tools/Validate-Documents.sh -IncludeRootGuides -IncludeAgentDocs -Fix
./tools/New-DadSession.sh -SessionId "YYYY-MM-DD-your-task" -TaskSummary "Describe the task"
```

## Pre-commit 훅

샘플 훅: `.githooks/pre-commit`

복제한 저장소에서 활성화하려면:

```bash
git config core.hooksPath .githooks
```

샘플 훅이 실행하는 명령:

- `tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs`
- `tools/Lint-StaleTerms.ps1`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

## 참고 사항

- 템플릿에는 기본적으로 live 세션이 포함되어 있지 않다.
- `Document/dialogue/`는 구조 placeholder를 제외하고 의도적으로 비어 있다.
- 첫 live 세션이 생성되기 전까지 `Validate-DadPacket.ps1`는 skip 메시지를 출력한다.
- `Document/dialogue/README.md`는 예상 세션 레이아웃과 summary 산출물을 문서화한다.
