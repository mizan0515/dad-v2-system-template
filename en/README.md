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

## What This Template Is For

Use this template when you want a repository to run a structured Codex + Claude Code workflow instead of relying on loose chat history.

In a real project, this template gives you:

- root contract files both agents read first
- a repeatable session and turn layout under `Document/dialogue/`
- validators for documents, packets, and Codex skill metadata
- reusable prompts, commands, and skills for common DAD workflows

This repository is a starter, not a live project by itself. The normal flow is:

1. copy the template into the real repository
2. replace placeholder rules with project-specific rules
3. register the Codex skills
4. start live DAD sessions and record turns as work happens

## Start With This, Not Everything

If you are new to the template, do not try to read every file first.

Read in this order:

1. this `README.md`
2. `PROJECT-RULES.md`
3. `AGENTS.md` and `CLAUDE.md`
4. `DIALOGUE-PROTOCOL.md`
5. `Document/DAD/` only when the protocol tells you to go there

If you only want the first successful setup, the critical path is:

1. fill in `PROJECT-RULES.md`
2. run document validation
3. set a project-specific skill namespace
4. validate Codex skill metadata
5. register the Codex Desktop skills
6. create the first session and the first turn

## Included

- Root contracts for Codex and Claude Code
- Shared project-rules template
- DAD v2 protocol
- Slash-command docs for session start / repeat workflow
- Skill docs for the same flows
- Session/bootstrap validators
- Core prompt set for audit, session start, handoff, recovery, debate, convergence closeout, migration, template review, emergency recovery, system-doc sync, and live-operations audit

## Runtime Requirements

- Windows: `powershell` 5.1 or `pwsh` 7.2+
- macOS / Linux / Git Bash: `pwsh` 7.2+ required
- Cross-platform wrapper scripts in `tools/*.sh` call the matching `.ps1` file through `pwsh` (or `powershell` when available on Windows shells)
- Command examples below use `pwsh`. On Windows PowerShell 5.1, replace `pwsh -File` with `powershell -ExecutionPolicy Bypass -File`.

## Recommended Setup Order

If you are using the template for the first time, follow this order.

### 1. Copy The Template Into The Real Repository

Copy this variant into the target repository root. Keep hidden folders such as `.agents`, `.claude`, `.githooks`, and `.prompts`.

### 2. Replace The Placeholder Repository Rules

Start with `PROJECT-RULES.md`. That file should describe the real repository, not the template.

Replace the placeholder text with:

- the real source-of-truth files
- the real build, test, and deployment guardrails
- the real git/PR closeout policy for converged DAD sessions
- the real operational constraints the agents must respect

Then review `AGENTS.md`, `CLAUDE.md`, and `DIALOGUE-PROTOCOL.md` and adjust only what needs to differ for the project.

### 3. Review The Prompt Pack You Actually Need

You do not need every prompt on day one. These are the common starting points:

- `.prompts/07-existing-project-migration.md` when adopting DAD v2 in an existing repository
- `.prompts/08-template-review-hardening.md` when reviewing and hardening the setup itself
- `.prompts/09-emergency-session-recovery.md` when session state or validator flow needs manual repair
- `.prompts/11-dad-operations-audit.md` when you want to audit the live process after real usage accumulates

### 4. Validate The Documents After Editing

Run the document validator once after you adapt the root contracts:

```powershell
pwsh -File tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix
```

This normalizes document formatting and applies the template BOM policy where appropriate.

One strict exception remains: `.agents/skills/*/SKILL.md` and `agents/openai.yaml` must stay UTF-8 without BOM because Codex Desktop expects YAML and frontmatter to start at byte 0.

### 5. Set A Repository-Specific Codex Skill Namespace

Before registration, replace the reserved template namespace:

```powershell
pwsh -File tools/Set-CodexSkillNamespace.ps1 -Namespace "your-project-prefix"
```

Why this matters:

- the template ships with the reserved namespace `dadtpl-`
- live repositories should not keep using that shared template prefix
- the namespace must stay aligned across folder names, frontmatter `name:` values, and desktop registration names

Use a short repository-specific prefix such as `acg-` or another stable project identifier.

### 6. Validate Codex Skill Metadata

```powershell
pwsh -File tools/Validate-CodexSkillMetadata.ps1 -Root .
```

Run this before registration or before enabling the sample hook. It catches namespace drift, BOM problems in runtime skill files, and malformed OpenAI metadata before those issues become harder to diagnose.

### 7. Register The Codex Desktop Skills

```powershell
pwsh -File tools/Register-CodexSkills.ps1
```

Codex Desktop does **not** auto-discover repository-local `.agents/skills/`.

Registration will:

- validate the skill metadata first
- link the skills into the `skills` directory under `$CODEX_HOME`
- clean up stale registrations that point to repositories that no longer exist

Registration refuses to continue while the template namespace `dadtpl-` is still active. Restart Codex Desktop after successful registration.

Keep the skill runtime files strict:

- `.agents/skills/*/SKILL.md` must be UTF-8 without BOM and begin with `---` at byte 0
- `.agents/skills/*/agents/openai.yaml` must be UTF-8 without BOM, single-document YAML, and ASCII-safe for Desktop display metadata

### 8. Add Project-Specific Prompts If Needed

If the repository needs more prompts than the shipped pack, add them under `.prompts/`. Keep frequently read root files thin and move detailed operational references into focused documents under `Document/`.

### 9. Create The First Session

```powershell
pwsh -File tools/New-DadSession.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -TaskSummary "Describe the task" `
  -Scope medium `
  -Mode hybrid
```

This creates the session scaffolding under `Document/dialogue/`. Pick a session ID that is stable and readable.

### 10. Create The First Turn

```powershell
pwsh -File tools/New-DadTurn.ps1 `
  -SessionId "YYYY-MM-DD-your-task" `
  -Turn 1 `
  -From codex
```

Create one turn file per actual agent turn. Prefer generating the packet skeleton with the helper instead of hand-writing it from scratch.

### 11. Record The Exact Handoff Prompt

On every turn closeout that hands work to the peer:

- save the exact peer handoff prompt to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`
- record that path in `handoff.prompt_artifact`
- paste the same text in the final reply

If the current turn is the final converged closeout, a new peer prompt may be absent. In that case, finish the summary/state artifacts and the git closeout required by `PROJECT-RULES.md` instead of fabricating a handoff artifact.

This keeps the session auditable and lets the next agent reconstruct the real handoff context.

## Typical Daily Workflow

Once the repository is adapted, the usual operating loop is:

1. open or continue one session for one coherent goal
2. create a new turn file whenever the speaking agent changes
3. let each agent work from the current packet plus the contract docs
4. save the exact handoff prompt used for the next agent
5. validate packets before marking the session done

Run packet validation after packet edits and before closing a session:

```powershell
pwsh -File tools/Validate-DadPacket.ps1 -Root . -AllSessions
```

`Validate-DadPacket.ps1` prints a skip message until the first live session exists. After that, treat it as part of the normal workflow.

Prefer short, session-scoped slices. When the task meaningfully changes, start a fresh session and explicitly close or supersede the previous one.

## File Size Design Rule

- Keep root contract docs and frequently read prompt docs thin enough to be read in one call by agent tooling.
- Move detailed protocol tables, lifecycle rules, and validation references into focused files under `Document/DAD/`.
- If a reference file becomes too large, split it by topic again instead of letting one monolithic Markdown file grow without bound.
- This avoids file-read and token-limit failures such as `file content exceeds maximum allowed tokens` when an agent is instructed to read a required file first.

## Bash Wrappers

For shells that prefer `bash`/`sh`, use the wrapper alongside each PowerShell script:

```bash
./tools/Validate-Documents.sh -IncludeRootGuides -IncludeAgentDocs -Fix
./tools/Set-CodexSkillNamespace.sh -Namespace "your-project-prefix"
./tools/Validate-CodexSkillMetadata.sh -Root .
./tools/Register-CodexSkills.sh
./tools/New-DadSession.sh -SessionId "YYYY-MM-DD-your-task" -TaskSummary "Describe the task"
```

## Pre-commit Hook

Sample hook: `.githooks/pre-commit`

To enable it in a cloned repository:

```bash
git config core.hooksPath .githooks
```

The sample hook runs:

- `tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -ReportLargeDocs -ReportLargeRootGuides -FailOnLargeDocs`
- `tools/Validate-CodexSkillMetadata.ps1 -Root .`
- `tools/Register-CodexSkills.ps1 -Root . -CodexHome .git/.codex-hook-validate -ValidateOnly`
- `tools/Lint-StaleTerms.ps1`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

The hook's registration dry-run intentionally fails while the reserved template namespace `dadtpl-` is still active. Apply `tools/Set-CodexSkillNamespace.ps1 -Namespace "<repo-prefix>"` before enabling the hook in a downstream repository.

## Common Mistakes To Avoid

- Do not use the template repository itself as a live session workspace.
- Do not leave `PROJECT-RULES.md` in placeholder form after copying.
- Do not skip skill namespace replacement before registration.
- Do not skip metadata validation before registration or hook enablement.
- Do not assume Codex Desktop will discover `.agents/skills/` automatically.
- Do not pre-seed fake dialogue sessions in the template.
- Do not forget to save the exact handoff prompt artifact for each turn that actually hands work to the peer.
- Do not assume `converged` session state alone means git closeout is done; define the final-turn PR policy in `PROJECT-RULES.md` and enforce it with `.prompts/06-convergence-pr-closeout.md`.

## Notes

- This template does not include a live session by default.
- `Document/dialogue/` is intentionally empty except for structure placeholders.
- `Validate-DadPacket.ps1` prints a skip message until the first live session exists.
- `Document/dialogue/README.md` documents the expected session layout and summary artifacts.
- Codex Desktop reads installed skills from the `skills` directory under `$CODEX_HOME`; it does not auto-index repository-local `.agents/skills/` without running the registration helper.
- The core DAD skills must keep one project-specific namespace prefix. Keep folder names, each skill frontmatter `name:` field, and global registration aligned through `tools/Set-CodexSkillNamespace.ps1`.
