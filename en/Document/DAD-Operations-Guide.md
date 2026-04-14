# DAD Operations Guide

## Purpose

This document describes the minimum operating sequence needed when enabling the DAD v2 template in another project for the first time.

## Startup Sequence

1. Fill in `PROJECT-RULES.md` for the target project.
2. Adjust the git / verification policy in `AGENTS.md` and `CLAUDE.md` if needed.
3. When introducing into an existing repository, first use `.prompts/07-existing-project-migration.md` to resolve conflict points.
4. On cross-platform environments, verify `pwsh` 7.2+ is installed (`tools/*.sh` wrappers and the pre-commit hook assume `pwsh`).
5. Run document validation once.
6. Create the first session.
7. Create the Turn 1 packet and start work.

Notes:
- The examples below assume `pwsh`.
- On Windows PowerShell 5.1 only, replace `pwsh -File` with `powershell -ExecutionPolicy Bypass -File`.

## First Session Creation

```powershell
pwsh -File tools/New-DadSession.ps1 `
  -SessionId "YYYY-MM-DD-task" `
  -TaskSummary "Describe the task" `
  -Scope medium `
  -Mode hybrid
```

## First Turn Creation

```powershell
pwsh -File tools/New-DadTurn.ps1 `
  -SessionId "YYYY-MM-DD-task" `
  -Turn 1 `
  -From codex
```

## Basic Validation

After document changes:

```powershell
pwsh -File tools/Validate-Documents.ps1 -IncludeRootGuides -IncludeAgentDocs -Fix
```

After session creation:

```powershell
pwsh -File tools/Validate-DadPacket.ps1 -Root . -AllSessions
```

## Operating Principles

- Root contract docs, commands, skills, prompts, and validators are treated as one system.
- If any of these change, align the related docs in the same task.
- If you cannot align them, record it as the first explicit next task.
- Right before convergence, use `.prompts/06-convergence-pr-closeout.md` as the checklist to avoid skipping summary, state, validation, or branch cleanup.
- If normal resume cannot recover the session, use `.prompts/09-emergency-session-recovery.md`.
