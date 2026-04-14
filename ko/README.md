# DAD v2 System Template

Reusable starter for a Dual-Agent Dialogue v2 workflow where Codex and Claude Code collaborate through:

- `AGENTS.md`
- `CLAUDE.md`
- `DIALOGUE-PROTOCOL.md`
- `.claude/commands/`
- `.agents/skills/`
- `.prompts/`
- `tools/`
- `Document/dialogue/`

## Included

- Root contracts for Codex and Claude Code
- Shared project-rules template
- DAD v2 protocol
- Slash-command docs for session start / repeat workflow
- Skill docs for the same flows
- Session/bootstrap validators
- Core prompt set for audit, session start, handoff, recovery, debate, convergence closeout, migration, template review, emergency recovery, and system-doc sync

## Runtime Requirements

- Windows: `powershell` 5.1 or `pwsh` 7.2+
- macOS / Linux / Git Bash: `pwsh` 7.2+ required
- Cross-platform wrapper scripts in `tools/*.sh` call the matching `.ps1` file through `pwsh` (or `powershell` when available on Windows shells)
- Command examples below use `pwsh`. On Windows PowerShell 5.1, replace `pwsh -File` with `powershell -ExecutionPolicy Bypass -File`.

## How To Adapt

1. Replace the placeholder content in `PROJECT-RULES.md` with the target repository's real source-of-truth and guardrails.
2. Adjust `AGENTS.md` / `CLAUDE.md` if the repo needs different git, test, or review policy.
3. Read `.prompts/07-기존-프로젝트-도입-마이그레이션.md` before introducing DAD v2 into an existing repository.
4. Use `.prompts/08-템플릿-검토-개선.md` when you want Claude Code to review and harden the template repository itself.
5. Keep `.prompts/09-비상-세션-복구.md` available for force-close, manual state repair, or validator-outage recovery.
6. Run document validation once after adapting the root contracts:

```powershell
pwsh -File tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs -Fix
```

7. Add project-specific prompts under `.prompts/` as needed.
8. Start the first session with:

```powershell
pwsh -File tools/New-DadSession.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -TaskSummary "Describe the task" `
  -Scope medium `
  -Mode hybrid
```

9. Create the first turn skeleton with:

```powershell
pwsh -File tools/New-DadTurn.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -Turn 1 `
  -From codex
```

## Bash Wrappers

For shells that prefer `bash`/`sh`, use the wrapper alongside each PowerShell script:

```bash
./tools/Validate-Documents.sh -IncludeRootGuides -IncludeAgentDocs -Fix
./tools/New-DadSession.sh -SessionId "YYYY-MM-DD-your-task" -TaskSummary "Describe the task"
```

## Pre-commit Hook

Sample hook: `.githooks/pre-commit`

To enable it in a cloned repository:

```bash
git config core.hooksPath .githooks
```

The sample hook runs:

- `tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs`
- `tools/Lint-StaleTerms.ps1`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

## Notes

- This template does not include a live session by default.
- `Document/dialogue/` is intentionally empty except for structure placeholders.
- `Validate-DadPacket.ps1` prints a skip message until the first live session exists.
- `Document/dialogue/README.md` documents the expected session layout and summary artifacts.
