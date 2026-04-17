## 2026-04-17 Session 1

### Completed
- Boot: read prototype state docs and verified baseline desktop build before new work.
- A7: relaxed the bounded prompt contract to marker-based handoff extraction and removed bounded CLI schema forcing.
- B4: added a dedicated `Latest Git / PR Activity` panel plus diagnostics and auto-log output.
- A2: added a broker-owned durable approval queue/history, wired interactive Codex approvals through it, and exposed an `Approval Queue` operator panel plus diagnostics output.
- G2 bridge: promoted unmanaged `mcp` / `web` activity from advisory-only into broker review items that can pause the session and be approved once or for the remainder of the session.
- A6 polish: surfaced matching saved session-approval rules directly in the pending approval and session-rule UI summaries.
- C1/G2: completed a real MCP capability audit for Codex and Claude, added `mcp-audit.md` / `capability-matrix.md`, and tightened MCP review policy so read-only resource discovery and telemetry ping/status auto-clear through broker policy while other MCP activity still pauses for review.
- C2: completed a real shell/PowerShell capability audit using the TaskPulse DAD workspace, captured live relay shell evidence plus direct Claude shell evidence, and recorded the results in `shell-audit.md` / `capability-matrix.md` / `TESTING-CHECKLIST.md`.
- C3: completed the read-only tier of the git workflow capability audit. Captured live WPF-driven relay evidence (session `git-audit-20260417-111226`) plus direct Codex and direct Claude git evidence against the TaskPulse workspace, and recorded everything in `git-audit.md` / `capability-matrix.md` / `TESTING-CHECKLIST.md`. Surfaced a real product gap: Codex wraps every Windows command in `powershell.exe -Command '...'`, so `RelayApprovalPolicy.ClassifyCommandCategory` never matches the `git*`/`pr` categories for Codex on Windows, and the destructive-tier git approval flow is therefore currently unreachable for Codex on Windows in practice.

### Build status
- pass 2026-04-17 initial boot build
- pass 2026-04-17T09:41:18+09:00 after bounded prompt/adapter changes
- pass 2026-04-17T09:45:45+09:00 after latest git/pr activity panel changes
- pass 2026-04-17T10:11:05+09:00 after broker-owned approval queue/history changes
- pass 2026-04-17T10:29:18+09:00 after MCP/web review-item bridge changes
- pass 2026-04-17T10:42:11+09:00 after active session-rule visibility UI updates
- pass 2026-04-17T10:15:53+09:00 after MCP audit follow-through and MCP default review policy tightening
- pass 2026-04-17T11:03:00+09:00 baseline build confirmed before starting the git workflow audit

### Runtime verification
- Baseline build only. No new runtime verification yet in this session.
- `claude -p "Return exactly the word ok." --output-format json` returned success.
- `codex exec --json "Return exactly the word ok."` returned `ok` with expected warnings on stderr.
- `dotnet run --project .\RelayApp.Desktop\RelayApp.Desktop.csproj` launched successfully and was stopped after a short smoke start.
- `dotnet run --project .\RelayApp.Desktop\RelayApp.Desktop.csproj` launched successfully again after the WPF `Latest Git / PR Activity` panel was added.
- `dotnet run --project .\RelayApp.Desktop\RelayApp.Desktop.csproj` launched successfully again after the approval queue/history panel and broker queue wiring were added.
- `dotnet run --project .\RelayApp.Desktop\RelayApp.Desktop.csproj` launched successfully again after unmanaged MCP/web review-item handling was added.
- `dotnet run --project .\RelayApp.Desktop\RelayApp.Desktop.csproj` launched successfully again after active session-rule visibility UI updates.
- `claude -p "Return exactly the word ok." --output-format json` returned success after the MCP/web review bridge changes.
- `codex exec --json "Return exactly the word ok."` returned `ok` after the MCP/web review bridge changes.
- `codex mcp list` / `codex mcp get unityMCP` confirmed enabled Codex MCP config.
- `claude mcp list` / `claude mcp get UnityMCP` confirmed Claude MCP is workspace-dependent and available in `D:\Unity\card game`.
- Real Codex MCP turn succeeded with `manage_editor` + `telemetry_ping`.
- Real Claude MCP turn succeeded with direct `mcp__UnityMCP__manage_editor` telemetry ping and with MCP resource discovery.
- `dotnet run --project .\RelayApp.Desktop\RelayApp.Desktop.csproj` launched successfully again after MCP default review policy tightening.
- Root maintainer validator still fails only on the pre-existing `en` variant issue: `Variant document validation failed for D:\dad-v2-system-template\en`.
- Real WPF-driven QA succeeded for the shell audit session `shell-audit-20260417-102903`; the broker recorded `shell: completed=8, requested=8` and accepted the handoff to Claude.
- Direct Claude shell audit against `D:\dad-relay-mvp-temp` succeeded and returned `ok` after structured Bash-based repository inspection.
- Real WPF-driven git audit session `git-audit-20260417-111226` ran in INTERACTIVE mode, completed Codex Turn 1 with 11 `shell.requested`/11 `shell.completed` events (including the five `git ...` commands), and accepted the handoff to Claude with an accurate read-only summary.
- Direct Codex git audit (`codex exec --json --cd D:/dad-relay-mvp-temp ...`) returned `ok` and each wrapped `powershell.exe -Command 'git ...'` completed with exit 0.
- Direct Claude git audit (`claude -p ... --output-format stream-json`) returned `ok` using a single compound Bash call chaining the four read-only git commands.

### Next priority
- C3 follow-up: live end-to-end exercise of destructive-tier git operations (`git add`, `git commit`, `git push`, `gh pr create`) through the relay, plus closing the Codex/Windows PowerShell-wrapping classifier gap in `RelayApprovalPolicy.ClassifyCommandCategory` so the `git-add` / `git-commit` / `git-push` / `pr` approval classes are actually reachable for Codex on Windows.

### Blockers or decisions needed
- Claude remains audit-only by design; no blocker for this session, but full approval parity still depends on a later product decision.
- Root source-repo validator still fails on the pre-existing `en` variant maintainer path and is unrelated to prototype changes.
- The shell audit exposed a likely UI refresh timing issue during long-running live turns; final state was correct, but near-real-time state refresh should be re-checked in a follow-up QA slice before treating it as a confirmed product bug.
- Codex-on-Windows wraps every command in `powershell.exe -Command '...'`, so the current `RelayApprovalPolicy.ClassifyCommandCategory` does not route git/pr work through the dedicated `git-add`/`git-commit`/`git-push`/`pr` approval classes. This is recorded as a follow-up gap rather than a blocker for read-only inspection.
