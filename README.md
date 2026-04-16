# DAD v2 System Template

Reusable starter for a **Dual-Agent Dialogue v2** workflow where Codex and Claude Code collaborate through symmetric turns.

This repository is the **template source repository**, not a live DAD runtime.

## Start Here

Choose one path first:

- If you are **maintaining the template itself**, work in this repository root and keep `en/` and `ko/` aligned.
- If you want to **use DAD v2 in a real project**, do **not** start live sessions here. Copy exactly one variant into the target repository, then work in that copied repository.

Fastest path for a real project:

1. copy `en/` or `ko/` into the target repository
2. fill in `PROJECT-RULES.md`
3. run `tools/Validate-Documents.ps1`
4. run `tools/Set-CodexSkillNamespace.ps1`
5. run `tools/Validate-CodexSkillMetadata.ps1`
6. run `tools/Register-CodexSkills.ps1`
7. create the first session and turn

## Variants

| Variant | Directory | Language |
|---------|-----------|----------|
| Korean (mixed Ko/En) | [`ko/`](./ko) | Korean prose, English code/identifiers |
| English only | [`en/`](./en) | English throughout |

The two variants are functionally equivalent. Pick the one that matches the language your team actually works in.

Both variants ship the same building blocks:

- root contracts (`AGENTS.md`, `CLAUDE.md`, `DIALOGUE-PROTOCOL.md`, `PROJECT-RULES.md`)
- `.claude/commands/` slash commands
- `.agents/skills/` OpenAI/Codex skills
- `.prompts/` reusable prompt library (11 prompts)
- `tools/` validators and session helpers
- `.githooks/pre-commit` sample hook
- `Document/dialogue/` session skeleton plus `backlog.json` admission registry
- `Document/` reference and operating guides

The source repository itself also includes root maintainer contracts:

- `PROJECT-RULES.md`
- `AGENTS.md`
- `CLAUDE.md`
- `DIALOGUE-PROTOCOL.md`

## How To Use This Repository

Think of this repository as a packaging source for two ready-to-copy DAD setups.

### 1. Pick A Variant

- Use [`en/`](./en) for fully English repositories and teams.
- Use [`ko/`](./ko) for Korean-speaking teams that still keep code and protocol-required identifiers in English.

### 2. Copy The Variant Into The Target Repository

Choose **one** of the following variants. Do not copy both into the same target repository.

```bash
# macOS / Linux / Git Bash: run only one of these commands
cp -r en/. /path/to/target-repo/     # English variant
cp -r ko/. /path/to/target-repo/     # Korean/English mixed variant
```

```powershell
# Windows PowerShell: run only the variant you want
robocopy en C:\path\to\target-repo /E
robocopy ko C:\path\to\target-repo /E
```

Make sure hidden folders such as `.agents`, `.claude`, `.githooks`, and `.prompts` are copied too.

### 3. Adapt The Copied Repository

In the copied repository, the first tasks are usually:

1. update `PROJECT-RULES.md` to describe the real repository's source of truth and guardrails
2. review `AGENTS.md`, `CLAUDE.md`, and `DIALOGUE-PROTOCOL.md`
3. validate documents
4. replace the reserved template skill namespace
5. validate Codex skill metadata
6. register the Codex Desktop skills
7. start the first DAD session and turn

Typical commands in the copied repository:

```powershell
pwsh -File tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix
pwsh -File tools/Set-CodexSkillNamespace.ps1 -Namespace "your-project-prefix"
pwsh -File tools/Validate-CodexSkillMetadata.ps1 -Root .
pwsh -File tools/Register-CodexSkills.ps1
pwsh -File tools/New-DadSession.ps1 -SessionId "YYYY-MM-DD-your-task" -TaskSummary "Describe the task" -Scope medium -Mode hybrid
pwsh -File tools/New-DadTurn.ps1 -SessionId "YYYY-MM-DD-your-task" -Turn 1 -From codex
```

For detailed downstream instructions, read the copied variant's README:

- [`en/README.md`](./en/README.md)
- [`ko/README.md`](./ko/README.md)

## Runtime Requirements

- Windows: `powershell` 5.1 or `pwsh` 7.2+
- macOS / Linux / Git Bash: `pwsh` 7.2+ required
- `tools/*.sh` wrappers call the matching `.ps1` through `pwsh` (or `powershell` on Windows shells)
- Variant skill runtime files (`.agents/skills/*/SKILL.md`, `agents/openai.yaml`) are intentionally UTF-8 without BOM because Codex/Desktop loaders expect YAML/frontmatter at byte 0

## Maintainer Checks

This source repository contains two parallel variants. Validate both the variants themselves and their parity before publishing or copying updates downstream.

```powershell
powershell -ExecutionPolicy Bypass -File tools/Validate-TemplateVariants.ps1 -RunVariantValidators
```

This maintainer check runs the variant document validator, Codex skill metadata validator, stale-term lint, DAD packet validator, DAD backlog validator, and a non-mutating Codex skill registration dry-run for both `en/` and `ko/` in one pass. The dry-run does not create links, manifests, or stale-registration cleanup side effects. It also validates the source-repo root contracts for required files, large-doc limits, and broken local Markdown links.

To enable the source-repository sample hook:

```bash
git config core.hooksPath .githooks
```

## Why The Protocol Is Split

- Root contract files are often read first by coding agents and can hit file-size or token limits if they become monolithic.
- This template keeps root contracts thin and moves detailed DAD rules into `en/Document/DAD/` and `ko/Document/DAD/`.
- If a frequently read file grows too large, split it by topic instead of relying only on chunked-read fallback behavior.
- Pre-commit and maintainer checks should fail when frequently read docs grow past the configured large-document threshold, including root maintainer contracts such as `AGENTS.md`, `CLAUDE.md`, and `DIALOGUE-PROTOCOL.md`, so this rule stays enforced instead of becoming advisory only.
