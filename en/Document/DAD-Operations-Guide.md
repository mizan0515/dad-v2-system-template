# DAD Operations Guide

## Purpose

This document describes the minimum operating sequence needed when enabling the DAD v2 template in another project for the first time.

If you only want the shortest successful onboarding path, follow `README.md` first and come here after the initial setup works.

## Operating Model

- DAD v2 is a **user-bridged** workflow. Auto mode reduces questions and convergence friction; it does not remove the relay step.
- Treat `Document/dialogue/state.json` as the current-session source of truth and `Document/dialogue/sessions/{session-id}/` as the durable artifact bundle.
- Treat `Document/dialogue/backlog.json` as the admission layer for future sessions, not as an execution log.
- Treat the rendered peer prompt as a durable artifact too: when a turn actually hands off to the peer, save it as `turn-{N}-handoff.md`, record that path in `handoff.prompt_artifact`, and paste the same text in the same final handoff reply.
- Do not require a follow-up user message such as "give me the next prompt." If another peer turn remains, the relay prompt is part of the current turn closeout.
- Leave `handoff.ready_for_peer_verification` false while a turn is still in progress. Flip it to true only after `handoff.next_task`, `handoff.context`, and the saved handoff artifact are all finalized.
- If a turn must stop without a peer handoff and without converging, mark it explicitly as `handoff.closeout_kind: recovery_resume`, keep `my_work.confidence: low`, and explain the blocker in `open_risks`.
- `DIALOGUE-PROTOCOL.md` is intentionally thin. Read detailed schema and validation references under `Document/DAD/` when needed.
- Prefer outcome-scoped sessions: each session should aim to produce a concrete artifact, verified decision, or explicit risk disposition.
- Keep the current session's continuation in `handoff.next_task`. Use backlog only when the work needs a different session.
- Do not open a new session only for wording correction, summary/state sync, closure seal, or validator-noise cleanup unless you are explicitly repairing broken DAD state or packet/schema drift.
- Every new non-recovery session must link to exactly one backlog item. `tools/New-DadSession.ps1` can auto-bootstrap that linkage only when the user starts from fresh work and no reusable `now` item already exists.
- If an active session already exists, newly discovered future work should stay queued in backlog until that session is closed or explicitly superseded.
- Do not open backlog-only sessions or peer debates just to reprioritize the queue; record the candidate during the active session's closeout instead.
- When a session converges, is blocked, or is superseded, resolve or re-queue the linked backlog item in that same closeout path so the admission layer does not retain a stale `promoted` owner.
- Dedicated peer-verify-only turns are justified only for remote-visible mutations, config/runtime decisions, high-risk measurements, destructive cleanup, or provenance/compliance-sensitive work.
- Prefer multiple short, session-scoped slices over one long umbrella session when the task meaningfully changes.
- When a new session replaces the current one, close or supersede the old session explicitly instead of silently drifting away from it.
- Codex/OpenAI skills in `.agents/skills/` are configured for **explicit invocation** (`allow_implicit_invocation: false`). Call them by name.
- Core DAD skills must use one project-specific namespace prefix across folder names, each skill frontmatter `name:` field, and Codex registration names. The template default `dadtpl-` prefix is reserved for template maintenance only.
- Codex Desktop does not auto-index repository-local `.agents/skills/`. First run `tools/Set-CodexSkillNamespace.ps1 -Namespace <project-prefix>`, then register them into the `skills` directory under `$CODEX_HOME` with `tools/Register-CodexSkills.ps1`, then restart Codex Desktop. Re-running the registration also clears stale managed links whose original repository path disappeared.
- Keep each skill's OpenAI metadata file ASCII-safe. Codex/Desktop skill registration is more reliable when display metadata stays free of locale-specific encoding drift.
- Keep `.agents/skills/*/SKILL.md` and `.agents/skills/*/agents/openai.yaml` as UTF-8 without BOM. Codex/Desktop loaders expect frontmatter and YAML to start at byte 0, so a document-wide BOM policy must not rewrite these runtime files.

## Startup Sequence

1. Fill in `PROJECT-RULES.md` for the target project.
2. Adjust the git / verification policy in `AGENTS.md` and `CLAUDE.md` if needed.
3. When introducing into an existing repository, first use `.prompts/07-existing-project-migration.md` to resolve conflict points.
4. On macOS, Linux, and Git Bash, verify `pwsh` 7.2+ is installed. On Windows, ensure either `pwsh` 7.2+ or `powershell` is available on PATH before relying on `tools/*.sh` wrappers or the pre-commit hook.
5. Run document validation once.
6. Set the Codex skill namespace for this repository.
7. Validate Codex skill metadata.
8. Register the Codex Desktop skills once for this repository.
9. Create the first session.
10. Create the Turn 1 packet and start work.

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
pwsh -File tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix
```

Apply a project-specific namespace before registration:

```powershell
pwsh -File tools/Set-CodexSkillNamespace.ps1 -Namespace "your-project-prefix"
```

Validate skill metadata before registration or commit:

```powershell
pwsh -File tools/Validate-CodexSkillMetadata.ps1 -Root .
```

This validator also rejects BOM-prefixed `SKILL.md`, BOM-prefixed `openai.yaml`, and multi-document YAML separators in skill metadata.

Dry-run the registration helper before commit or hook rollout:

```powershell
pwsh -File tools/Register-CodexSkills.ps1 -Root . -CodexHome .git/.codex-hook-validate -ValidateOnly
```

This validates registration-time path and collision logic without creating links or manifests.
If the reserved template namespace `dadtpl-` is still active, this dry-run fails by design. Apply a project namespace before turning on the sample pre-commit hook.

If you invoke the validator from outside the repository root, pass an explicit root path:

```powershell
pwsh -File tools/Validate-Documents.ps1 -Root "C:\path\to\target-repo" -IncludeRootGuides -IncludeAgentDocs
```

After session creation:

```powershell
pwsh -File tools/Validate-DadPacket.ps1 -Root . -AllSessions
pwsh -File tools/Validate-DadBacklog.ps1 -Root .
```

## Operating Principles

- Root contract docs, commands, skills, prompts, and validators are treated as one system.
- If any of these change, align the related docs in the same task.
- If you cannot align them, record it as the first explicit next task.
- Open or continue sessions for concrete outcomes, not ceremony. Wording-only, summary/state-sync-only, closure-seal-only, and validator-noise-only work should stay inside the active execution session unless the DAD system itself needs repair.
- Keep peer verification risk-gated. A dedicated verify-only relay should be the exception for remote-visible, hard-to-reverse, config/runtime-sensitive, measurement-sensitive, destructive, or provenance/compliance-sensitive work.
- Prefer a fresh session when the goal, verification surface, or task ownership meaningfully changes instead of stretching one session across unrelated work.
- Closed or superseded sessions still need `summary.md` plus the named closed-session summary artifact.
- Right before convergence, use `.prompts/06-convergence-pr-closeout.md` as the checklist to avoid skipping summary, state, validation, or branch cleanup.
- If the session converges on the current turn and no peer handoff remains, the same turn owner still needs to finish commit/push/PR or record a concrete blocker. Dialogue closeout and git closeout are related, but they are not the same thing.
- Summary/state sync, closure confirmation, and final wording cleanup are part of same-turn closeout, not a follow-on seal session.
- If normal resume cannot recover the session, use `.prompts/09-emergency-session-recovery.md`.
- When the system itself has been used for a while and you need to audit live behavior, use `.prompts/11-dad-operations-audit.md`.
- If this repository should stop owning the global Codex skill links, remove them with `pwsh -File tools/Unregister-CodexSkills.ps1` and restart Codex Desktop.
- Do not register the default template namespace `dadtpl-` into a live shared Codex environment; convert it to a project prefix first.
