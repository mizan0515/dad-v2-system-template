# DAD v2 System Template

Reusable starter for a **Dual-Agent Dialogue v2** workflow where Codex and Claude Code collaborate through symmetric turns.

This repository provides **two parallel variants** of the template. Pick one and copy the directory contents into the target repository root.

| Variant | Directory | Language |
|---------|-----------|----------|
| Korean (mixed Ko/En) | [`ko/`](./ko) | Korean prose, English code/identifiers |
| English only | [`en/`](./en) | English throughout |

Both variants ship the same:

- Root contracts (`AGENTS.md`, `CLAUDE.md`, `DIALOGUE-PROTOCOL.md`, `PROJECT-RULES.md`)
- `.claude/commands/` slash commands
- `.agents/skills/` OpenAI/Codex skills
- `.prompts/` reusable prompt library (10 prompts)
- `tools/` PowerShell validators and session helpers (+ `.sh` wrappers)
- `.githooks/pre-commit` sample hook
- `Document/dialogue/` empty session skeleton
- `Document/` operations guide

## Quick Start

```bash
# macOS / Linux / Git Bash
cp -r en/. /path/to/target-repo/     # English variant
cp -r ko/. /path/to/target-repo/     # Korean/English mixed variant
```

```powershell
# Windows PowerShell (includes hidden folders like .agents, .claude, .prompts)
robocopy en C:\path\to\target-repo /E
robocopy ko C:\path\to\target-repo /E
```

Then follow the variant's `README.md` (`en/README.md` or `ko/README.md`) for adaptation steps.

## Runtime Requirements

- Windows: `powershell` 5.1 or `pwsh` 7.2+
- macOS / Linux / Git Bash: `pwsh` 7.2+ required
- `tools/*.sh` wrappers call the matching `.ps1` through `pwsh` (or `powershell` on Windows shells)

## Which Variant Should I Pick?

- **`en/`** — distributing the template to non-Korean-speaking teams, or when every file must be English.
- **`ko/`** — Korean-speaking teams. Docs are Korean; code, identifiers, and protocol-required strings remain English.

The two variants are functionally equivalent. Pick by the natural language of your team, not by technical capability.
