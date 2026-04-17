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
- C3 follow-up (classifier fix): closed the Codex/Windows PowerShell-wrapping classifier gap. `RelayApprovalPolicy.ClassifyCommandCategory` now unwraps `"...\powershell.exe" -Command '<inner>'`, `pwsh -Command '<inner>'`, and `cmd /c <inner>` before matching on `git`/`git commit`/`git add`/`git push`/`gh pr create`, and strips `git -c key=value` / `git -C <path>` option pairs before subcommand matching. The Codex adapter now also refines `commandExecution` item categorization from the generic `shell` class to the more specific git/git-add/git-commit/git-push/pr class when the wrapped command warrants it.
- C3 destructive-tier live exercise: ran real `git add` / `git commit` / `git push` against a disposable `audit/destructive-20260417` branch of the TaskPulse workspace through the interactive relay (session `destructive-qa-20260417-131500`). Broker emitted `git.add.requested`/`.completed`, `git.commit.requested`/`.completed`, and `git.push.requested` + `approval.requested` + `approval.queue.enqueued` + `git.push.completed (declined)`. Codex-side sandbox runs `git add`/`git commit` directly without an approval round-trip, while `git push` correctly escalates to the broker as `item/commandExecution/requestApproval`. Surfaced a real product gap: `AutoApproveAllRequests=true` did not auto-resolve the server-originated push approval in the Codex interactive transport, so the push was denied by timeout and never reached the remote. Captured in `git-audit.md` and `capability-matrix.md`. `gh pr create` live exercise still pending (blocked on a real remote).

### Build status
- pass 2026-04-17 initial boot build
- pass 2026-04-17T09:41:18+09:00 after bounded prompt/adapter changes
- pass 2026-04-17T09:45:45+09:00 after latest git/pr activity panel changes
- pass 2026-04-17T10:11:05+09:00 after broker-owned approval queue/history changes
- pass 2026-04-17T10:29:18+09:00 after MCP/web review-item bridge changes
- pass 2026-04-17T10:42:11+09:00 after active session-rule visibility UI updates
- pass 2026-04-17T10:15:53+09:00 after MCP audit follow-through and MCP default review policy tightening
- pass 2026-04-17T11:03:00+09:00 baseline build confirmed before starting the git workflow audit
- pass 2026-04-17T11:57:00+09:00 after Codex/Windows PowerShell-wrapping classifier fix and Codex adapter category refinement
- pass 2026-04-17T13:15:00+09:00 baseline build before destructive-tier live exercise (no source changes in this slice)

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
- Post-fix WPF-driven QA session `git-classify-qa-20260417-115929` ran in INTERACTIVE mode, completed Codex Turn 1 with 5 `git.requested` / 5 `git.completed` events (the five wrapped `git ...` commands) alongside 4 `shell.requested` / 4 `shell.completed` events for the remaining non-git PowerShell commands. The `Latest Git / PR Activity` panel correctly surfaced the git events for the first time on Codex/Windows.
- Destructive-tier WPF-driven QA session `destructive-qa-20260417-131500` ran in INTERACTIVE mode on disposable branch `audit/destructive-20260417` of the TaskPulse workspace with `AutoApproveAllRequests=true`. Broker observed `git.add.requested`/`.completed` (exit 0), `git.commit.requested`/`.completed`, `git.push.requested` + `approval.requested` + `approval.queue.enqueued` + `git.push.completed (declined)`. `git add` and `git commit` ran inside Codex's sandbox without routing approvals to the broker; `git push` correctly escalated as `item/commandExecution/requestApproval` and was denied by timeout because `AutoApproveAllRequests` did not auto-resolve the server-originated approval.

### Next priority
- Honour `AutoApproveAllRequests` for server-originated `item/commandExecution/requestApproval` events in the Codex interactive transport. Currently the flag only affects operator-UI approvals; server-originated push approvals still time out when nobody is at the keyboard. Needs a broker-side auto-accept path in the approval-routing code.

### Loop status
- 2026-04-17 Session 1 paused after C3 read-only merge (PR #5). Context budget approaching the agreed threshold; resuming the loop on the next scheduled wake-up.
- 2026-04-17 Session 1 iteration 2: classifier fix shipped as PR #TBD; pausing after merge. Next iteration will take on the destructive-tier live exercise.
- 2026-04-17 Session 1 iteration 3: 컨텍스트 포화로 일시 정지. 이전 대화 요약으로 재진입했으나 C3 destructive-tier 라이브 실행(분리 브랜치 준비 + WPF UI Automation QA + JSONL 이벤트 검증)은 한 번의 턴에 안전하게 들어가지 않음. 다음 반복에서 `dev/git-destructive-live` 브랜치로 새로 시작 예정.
- 2026-04-17 Session 1 iteration 4: C3 destructive-tier add/commit/push 라이브 실행 완료. 다음 반복은 `AutoApproveAllRequests` 서버측 승인 자동 수락 구현으로 진행 예정.

### Blockers or decisions needed
- Claude remains audit-only by design; no blocker for this session, but full approval parity still depends on a later product decision.
- Root source-repo validator still fails on the pre-existing `en` variant maintainer path and is unrelated to prototype changes.
- The shell audit exposed a likely UI refresh timing issue during long-running live turns; final state was correct, but near-real-time state refresh should be re-checked in a follow-up QA slice before treating it as a confirmed product bug.
- ~~Codex-on-Windows wraps every command in `powershell.exe -Command '...'`, so the current `RelayApprovalPolicy.ClassifyCommandCategory` does not route git/pr work through the dedicated `git-add`/`git-commit`/`git-push`/`pr` approval classes.~~ (resolved — classifier now unwraps shell wrappers and adapter refines command-execution items from `shell` to the specific git category; verified live in QA session `git-classify-qa-20260417-115929`).
