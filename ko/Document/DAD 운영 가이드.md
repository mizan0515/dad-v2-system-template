# DAD 운영 가이드

## 목적

이 문서는 다른 프로젝트에서 DAD v2 템플릿을 처음 켤 때 필요한 최소 운영 순서를 설명한다.

처음 성공 경로만 빠르게 따라가려면 먼저 `README.md`를 보고, 초기 설정이 끝난 뒤 이 문서를 읽는 편이 낫다.

## 운영 모델

- DAD v2는 **user-bridged** 워크플로우다. auto 모드는 질문과 수렴 마찰을 줄일 뿐, 사용자 relay 단계를 제거하지 않는다.
- `Document/dialogue/state.json`은 현재 세션의 source of truth이고, `Document/dialogue/sessions/{session-id}/`는 durable artifact bundle이다.
- peer prompt도 durable artifact로 취급한다. 실제로 peer handoff를 내보내는 턴에서는 `turn-{N}-handoff.md`로 저장하고, 그 경로를 `handoff.prompt_artifact`에 기록한 뒤 같은 본문을 최종 handoff 응답에 그대로 출력한다.
- 턴이 진행 중일 때는 `handoff.ready_for_peer_verification`를 false로 유지하고, `handoff.next_task`, `handoff.context`, 저장된 handoff artifact가 모두 확정된 뒤에만 true로 올린다.
- `DIALOGUE-PROTOCOL.md`는 의도적으로 얇게 유지하고, 상세 스키마와 validation reference는 필요할 때 `Document/DAD/`에서 읽는다.
- 작업 의미가 바뀌면 하나의 긴 umbrella session보다 짧은 session-scoped slice를 여러 개 닫는 방식을 우선한다.
- 새 세션이 현재 세션을 대체하면 조용히 방치하지 말고 이전 세션을 명시적으로 close 또는 supersede한다.
- `.agents/skills/`의 Codex/OpenAI 스킬은 **명시 호출 전용**(`allow_implicit_invocation: false`)으로 설정되어 있으므로 이름으로 직접 호출한다.
- 핵심 DAD 스킬은 폴더명, 각 스킬 frontmatter의 `name:` 필드, Codex 등록 이름 전체에서 하나의 저장소 전용 namespace prefix를 유지해야 한다. 템플릿 기본 prefix인 `dadtpl-`는 템플릿 유지보수 전용이다.
- Codex Desktop는 저장소의 `.agents/skills/`를 자동 인덱싱하지 않는다. 먼저 `tools/Set-CodexSkillNamespace.ps1 -Namespace <project-prefix>`를 실행한 뒤 `tools/Register-CodexSkills.ps1`로 `$CODEX_HOME` 아래 `skills` 디렉터리에 등록하고 Codex Desktop를 재시작해야 한다. 재등록 시 원래 저장소 경로가 사라진 stale managed link도 함께 정리한다.
- 각 스킬의 OpenAI 메타데이터 파일은 ASCII-safe하게 유지한다. display metadata에 locale별 인코딩 drift가 섞이면 Codex/Desktop 등록 표시가 다시 깨질 수 있다.
- `.agents/skills/*/SKILL.md`와 `.agents/skills/*/agents/openai.yaml`은 UTF-8 without BOM을 유지해야 한다. Codex/Desktop loader는 frontmatter와 YAML이 byte 0에서 바로 시작한다고 가정하므로, 일반 문서용 BOM 정책이 이 런타임 파일을 다시 쓰지 않도록 해야 한다.

## 시작 순서

1. `PROJECT-RULES.md`를 해당 프로젝트에 맞게 채운다.
2. 필요하면 `AGENTS.md`, `CLAUDE.md`의 git / verification 정책을 조정한다.
3. 기존 저장소에 도입하는 경우 `.prompts/07-기존-프로젝트-도입-마이그레이션.md`를 먼저 사용해 충돌 지점을 정리한다.
4. macOS, Linux, Git Bash에서는 `pwsh` 7.2+가 설치되어 있는지 확인한다. Windows에서는 `tools/*.sh` wrapper나 pre-commit hook을 쓰기 전에 `pwsh` 7.2+ 또는 `powershell`이 PATH에 있는지 확인한다.
5. 문서 검증을 한 번 실행한다.
6. 이 저장소용 Codex 스킬 namespace를 설정한다.
7. Codex 스킬 메타데이터를 검증한다.
8. 이 저장소용 Codex Desktop 스킬을 한 번 등록한다.
9. 첫 세션을 생성한다.
10. Turn 1 packet을 만들고 작업을 시작한다.

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
pwsh -File tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix
```

등록 전에 저장소 전용 namespace를 적용한다:

```powershell
pwsh -File tools/Set-CodexSkillNamespace.ps1 -Namespace "your-project-prefix"
```

커밋 또는 등록 전에 스킬 메타데이터를 검증한다:

```powershell
pwsh -File tools/Validate-CodexSkillMetadata.ps1 -Root .
```

이 validator는 BOM이 붙은 `SKILL.md`, BOM이 붙은 `openai.yaml`, multi-document YAML separator가 들어간 skill metadata도 함께 거부한다.

커밋 전이나 훅 배포 전에 registration helper도 dry-run으로 검증한다:

```powershell
pwsh -File tools/Register-CodexSkills.ps1 -Root . -CodexHome .git/.codex-hook-validate -ValidateOnly
```

이 경로는 link나 manifest를 만들지 않고 registration 시점의 경로/충돌 로직만 검증한다.
예약된 템플릿 namespace `dadtpl-`가 그대로 남아 있으면 이 dry-run은 의도적으로 실패한다. 샘플 pre-commit 훅을 켜기 전에 먼저 프로젝트 namespace를 적용해야 한다.

저장소 루트 밖에서 validator를 호출하면 `-Root`에 저장소 절대 경로를 명시한다.

```powershell
pwsh -File tools/Validate-Documents.ps1 -Root "C:\path\to\target-repo" -IncludeRootGuides -IncludeAgentDocs
```

세션 생성 후:

```powershell
pwsh -File tools/Validate-DadPacket.ps1 -Root . -AllSessions
```

## 운영 원칙

- 루트 계약 문서, command, skill, prompt, validator는 한 시스템으로 본다.
- 이 중 하나가 바뀌면 관련 문서를 같이 맞춘다.
- 못 맞추면 다음 작업의 첫 항목으로 명시한다.
- 목표, 검증 표면, 작업 소유 범위가 바뀌면 하나의 세션을 억지로 늘리지 말고 새 세션을 연다.
- 종료되거나 supersede된 세션도 `summary.md`와 named closed-session summary를 남긴다.
- 수렴 직전에는 `.prompts/06-수렴-종료-PR-정리.md`를 기준으로 summary, state, validation, 브랜치 정리를 빠뜨리지 않는다.
- 세션이 현재 턴에서 수렴하고 더 이상 peer handoff가 남지 않더라도, 같은 턴 담당자가 commit/push/PR을 끝내거나 구체적인 blocker를 남겨야 한다. dialogue closeout과 git closeout은 연결돼 있지만 동일한 단계는 아니다.
- 일반 재개로 복구할 수 없으면 `.prompts/09-비상-세션-복구.md`를 사용한다.
- 시스템이 실제로 운용된 뒤 live artifact 기준 운영 감사를 하려면 `.prompts/11-DAD-운영-감사.md`를 사용한다.
- 이 저장소가 전역 Codex 스킬 링크를 더 이상 소유하지 않아야 하면 `pwsh -File tools/Unregister-CodexSkills.ps1`를 실행하고 Codex Desktop를 재시작한다.
- 공유 Codex 환경에 템플릿 기본 namespace `dadtpl-`를 그대로 등록하지 말고, 먼저 프로젝트 prefix로 바꾼다.
