# DAD 운영 가이드

## 목적

이 문서는 다른 프로젝트에서 DAD v2 템플릿을 처음 켤 때 필요한 최소 운영 순서를 설명한다.

## 시작 순서

1. `PROJECT-RULES.md`를 해당 프로젝트에 맞게 채운다.
2. 필요하면 `AGENTS.md`, `CLAUDE.md`의 git / verification 정책을 조정한다.
3. 기존 저장소에 도입하는 경우 `.prompts/07-기존-프로젝트-도입-마이그레이션.md`를 먼저 사용해 충돌 지점을 정리한다.
4. 크로스플랫폼 환경이면 `pwsh` 7.2+가 설치되어 있는지 확인한다 (`tools/*.sh` wrapper와 pre-commit hook은 `pwsh` 기준).
5. 문서 검증을 한 번 실행한다.
6. 첫 세션을 생성한다.
7. Turn 1 packet을 만들고 작업을 시작한다.

참고:
- 아래 예시는 `pwsh` 기준이다.
- Windows PowerShell 5.1만 있는 환경이면 `pwsh -File` 대신 `powershell -ExecutionPolicy Bypass -File`로 바꿔 실행한다.

## 첫 세션 생성

```powershell
pwsh -File tools/New-DadSession.ps1 `
  -SessionId "YYYY-MM-DD-task" `
  -TaskSummary "Describe the task" `
  -Scope medium `
  -Mode hybrid
```

## 첫 턴 생성

```powershell
pwsh -File tools/New-DadTurn.ps1 `
  -SessionId "YYYY-MM-DD-task" `
  -Turn 1 `
  -From codex
```

## 기본 검증

문서 변경 후:

```powershell
pwsh -File tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs -Fix
```

세션 생성 후:

```powershell
pwsh -File tools/Validate-DadPacket.ps1 -Root . -AllSessions
```

## 운영 원칙

- 루트 계약 문서, command, skill, prompt, validator는 한 시스템으로 본다.
- 이 중 하나가 바뀌면 관련 문서를 같이 맞춘다.
- 못 맞추면 다음 작업의 첫 항목으로 명시한다.
- 수렴 직전에는 `.prompts/06-수렴-종료-PR-정리.md`를 기준으로 summary, state, validation, 브랜치 정리를 빠뜨리지 않는다.
- 일반 재개로 복구할 수 없으면 `.prompts/09-비상-세션-복구.md`를 사용한다.
