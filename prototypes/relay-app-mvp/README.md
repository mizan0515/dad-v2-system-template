# Relay App MVP Prototype

This folder contains the first buildable scaffold for the relay app MVP.

## Projects

- `RelayApp.Core`
  - broker
  - handoff parser
  - adapter interfaces
  - lightweight persistence
- `RelayApp.Desktop`
  - WPF shell
  - broker wiring
- `RelayApp.CodexProtocol`
  - reusable `codex app-server` protocol client
  - spike runner and one-shot turn runner
- `RelayApp.CodexProtocol.Spike`
  - console entry point for protocol verification against a real local Codex install

## Current status

This is still an MVP, but the relay path itself is functional.

Implemented:

- strict handoff JSON parsing
- snake_case handoff schema serialization aligned with the broker docs
- per-session JSON state store
- per-session JSONL event log
- relay broker with repair loop
- WPF shell showing state, logs, and latest handoff
- live usage capture from experimental transports into broker state and event log
- first budget circuit breakers for output growth and Claude-side repeated low-cache turns
- initial turn-count and wall-clock session rotation in the broker
- Claude-side CLI-estimated USD cost capture and normalized Codex cached-input accounting
- corrected Codex output-token accounting so reasoning is not double-counted
- corrected Codex token extraction to read `tokenUsage.total` in the app-server notification shape
- interactive runtime can now retry a budget-tripped turn through bounded CLI fallback using a fresh fallback context
- bounded fallback retries now log when retry usage is unknown, and Claude fallback runs with its own spend cap
- bounded Claude and Codex fallback adapters now return usage when the underlying CLI payload exposes it
- bounded Codex usage capture now reads the real `codex exec --json` `turn.completed.usage` shape instead of assuming app-server JSON-RPC notifications
- broker now converts cumulative Codex thread totals into per-turn deltas by handle before applying budget counters
- desktop CLI process launches on Windows are now attached to Job Objects so cancellation/closure is more likely to tear down descendant Codex processes
- broker now drops native session handles on reload so a restarted app cannot double-count resumed cumulative Codex usage with a lost in-memory baseline
- when a persisted session reloads after a crash/restart, the broker now writes a `session.reloaded` event so operators can see that transport continuity was intentionally reset
- Windows CLI launches now use a suspended-create path before Job Object attach, reducing the child-process escape race that existed when attachment happened after `Process.Start()`
- Codex turns now include estimated USD cost so session cost is no longer Claude-only
- Codex cost estimation now resolves the locally configured Codex model from `%CODEX_HOME%\\config.toml` or `%USERPROFILE%\\.codex\\config.toml`, including root profile selection when present, and falls back to the default rate card otherwise
- Claude usage diagnostics now surface `model_usage` entries when the CLI returns per-model vendor cost data
- the broker now emits advisory events when Claude reports tokens without cost (`claude.cost.absent`), when a configured Claude ceiling is inactive for the current session segment because auth is not api-key (`cost.ceiling.disabled`), when Claude cache-creation tokens look inflated enough to match the known CLI bug (`cache.inflation.suspected`), and when Codex pricing falls back to the default rate card (`codex.pricing.fallback`)
  - these advisories are emitted once per session segment and reset on broker rotation, so the event log stays actionable instead of repeating the same warning every turn
- the broker now pauses on any non-timeout adapter exception, not just budget trips and timeout, and emits `adapter.usage_unknown` when a primary turn completes without usage metrics so untracked spend is visible in the event log
- the interactive Claude adapter now treats a missing terminal `result` line as a hard turn failure, validates its health probe output instead of assuming success, and runs under the same Job Object options as the bounded desktop adapters
- interactive Codex protocol launches now also run under injected Job Object options, closing the last Windows adapter parity gap for process-lifetime limits
- Codex usage and pricing-fallback events now stamp the local rate-card version/as-of metadata, and the broker prunes stale cumulative-handle baselines both on rotation and when an active side replaces its session handle
- when the local Codex rate card ages past a safety horizon, the broker emits `codex.rate_card.stale` once per session segment so operators can see that Codex USD estimates may have drifted
- the Codex protocol client now serializes JSON-RPC writes and drops canceled pending RPC entries promptly so interactive protocol state does not accumulate stale request bookkeeping
- the Codex protocol client now also bounds server-request reply writes with a timeout and cancels queued notification waiters on disposal, reducing leftover protocol-side state during abnormal teardown
- the broker can now rotate on a configurable Claude-only estimated cost ceiling (`MaxClaudeCostUsd`) for each session segment when Claude auth is recognized as api-key (`api-key`, `apiKey`, `api_key`, and `apikey` all count); non-api-key auth keeps the ceiling inactive because Claude CLI USD is informational there
- Windows Job Objects now also enforce per-job CPU-time, active-process-count, and memory ceilings in addition to kill-on-close cleanup
- Relay thresholds can now be overridden from `%LocalAppData%\\RelayAppMvp\\broker.json`, including per-turn timeout and Job Object limits
- recent event summary panel for fast failure triage
- smoke test report panel with PASS/FAIL summary
- smoke test report includes session and adapter handles for follow-up debugging
- export diagnostics button that writes a markdown packet under `%LocalAppData%\RelayAppMvp\diagnostics`
- the desktop app now also keeps auto-updating readable status snapshots under `%LocalAppData%\RelayAppMvp\auto-logs` so operators can inspect the latest adapter status, state summary, recent events, and accepted handoff without manually exporting diagnostics
- the broker now writes initial action-level events from live adapters into the session JSONL log (`adapter.event`, `tool.invoked`, `tool.completed`, `tool.failed`, and `approval.requested` when the transport exposes them), so turns are no longer observable only through final handoff JSON
- when a live adapter surfaces `approval.requested` without a transport response path, the broker now pauses the relay instead of silently continuing, and the desktop UI shows the latest approval activity separately from the generic recent-event stream
- pending approval is now a first-class session-state concept rather than only a log line; the desktop UI and exported diagnostics show it directly through `AwaitingApproval` state and a persisted `PendingApproval` payload
- the broker now also keeps a durable `ApprovalQueue` history so approval requests and their final states (`pending`, `approved_once`, `approved_session`, `denied`, `expired`) survive outside the transient operator dialog flow
- interactive Codex turns now request runtime approval (`approvalPolicy=on-request`) instead of suppressing approval entirely, and supported approval requests can now round-trip through desktop approve/deny buttons back into `codex app-server`
- broker-side approval pause now only triggers for unresolved approval requests; turns that already produced `approval.granted` or `approval.denied` no longer get incorrectly re-paused at turn end
- interactive Codex approval requests now classify common command categories such as `git`, `git-push`, `pr`, and `shell` for clearer operator review
- the first default git safety rules are now active for interactive Codex approvals: read-only `git status` / `git diff` / `git log` are auto-approved once, while destructive `git push --force` and `git reset --hard` are auto-denied before the operator is prompted
- direct `git push` requests to protected branches such as `main`, `master`, `trunk`, `production`, `release/*`, and `hotfix/*` are now blocked by default, and PRs targeting protected base branches are elevated to critical-risk approval items
- the default approval policy now also auto-denies clearly destructive shell commands such as `rm -rf`, `Remove-Item -Recurse`, `del /f`, `rmdir /s`, `format`, `shutdown`, and `Stop-Computer`
- the default approval policy now also blocks Codex permission-escalation requests for additional network access or broad filesystem access, and blocks file-change approvals that target protected git metadata paths such as `.git/` and `.gitmodules`
- pending approvals and saved session approval rules now carry a broker-assigned risk level (`low`, `medium`, `high`, `critical`) so operators can distinguish read-only git inspection from push, permission escalation, MCP, and protected-path changes at a glance
- approval-related observed actions now preserve category/title metadata into broker state, and automatic allow/deny decisions emit a separate `policy.applied` event before the resulting approval decision is logged
- interactive Codex approvals now also emit category-specific audit events such as `git.commit.requested`, `git.push.granted`, and `pr.requested.denied`-style entries where applicable, and the desktop UI shows human-friendly approval titles instead of raw transport method names
- `Approve Session` now creates broker-owned session approval rules so matching later requests in the same relay session can auto-resolve without reopening the approval panel every time
- session approval rules for `git push` and `gh pr create` are now narrowed by parsed remote/branch or head/base metadata, so a session-level allow no longer opens every future push or PR in that session
- the desktop UI now shows saved session approval rules explicitly and lets the operator clear them mid-session, with `approval.session_rules.cleared` logged into the broker event stream
- interactive Codex command approvals now include a human-readable default policy hint in the approval message so the operator can tell at a glance whether the command is read-only, requires approval, or is blocked by default
- `git commit`, `git push`, and `gh pr create` approvals now include a short command summary in the approval message, such as commit message, push destination, or pull-request title/base/head when those flags are present
- a dangerous operator-only mode now exists that auto-approves all approval requests while still writing `approval.auto_mode.applied` events to the broker log; this is intentionally visible in the UI state summary and diagnostics export
- Claude `stream-json` action capture now classifies Bash tool calls into git/shell/pr-style categories where possible and records permission denials as structured approval-denied audit events, even though Claude still lacks full broker-routed approval UX
- Claude `stream-json` now also emits category-specific action events such as `git.commit.requested`, `git.push.requested`, `pr.requested`, and `shell.denied` when those commands can be classified from Bash tool input or permission denial payloads
- generic Claude tool calls are now classified into broker-visible categories such as `mcp`, `web`, `file-change`, and `tool`, so MCP and non-Bash tool activity no longer collapses into a single undifferentiated audit event
- Codex interactive and bounded `exec` item events now also carry category/title metadata and emit category-specific audit events for non-agent tool activity, including MCP- and web-shaped item types when the transport exposes them
- when MCP or web tool activity is observed without broker-routed approval, the broker now emits `mcp.review_required` / `web.review_required` advisory events once per session segment and raises a broker-side pending review item so operators can explicitly approve once or approve for the rest of the session
- those MCP/web review items now use session approval rules too, so repeated use of the same reviewed MCP/web tool in one session no longer re-pauses the relay once the operator approves it for the session
- the first MCP-specific default review rules are now active: resource discovery (`ListMcpResourcesTool`, `ReadMcpResourceTool`) and read-only telemetry ping/status actions auto-clear through broker policy, while other MCP activity still raises operator review items
- the desktop UI, diagnostics export, and auto-log snapshots now show a dedicated `Latest Tool Activity` summary so operators can see recent MCP/tool behavior without scanning the full event log
- the desktop UI, diagnostics export, and auto-log snapshots now also show a dedicated `Latest Git / PR Activity` summary so commit/push/PR behavior can be reviewed separately from generic tool traffic
- the desktop UI, diagnostics export, and auto-log snapshots now also show an `Approval Queue` summary so operators can review queued approval history without reading raw JSONL logs
- the desktop UI now also shows when the current pending approval already matches a saved session approval rule, reducing ambiguity around what `Approve Session` has already unlocked
- the desktop UI, diagnostics export, and auto-log snapshots now also show a `Tool Category Summary`, grouping session activity by categories such as `git.push`, `mcp`, `web`, and `shell`
- the desktop UI, diagnostics export, and auto-log snapshots now also show a `Policy Gap Summary`, surfacing unmanaged `mcp` / `web` activity that still needs future approval-policy hardening
- the desktop UI now also highlights pending approvals by broker-assigned risk level and highlights the policy-gap panel whenever unmanaged `mcp` / `web` activity has been observed in the current session segment
- the desktop UI, diagnostics export, and auto-log snapshots now also expose a `Current Session Risk Summary`, combining pending approval risk, saved high-risk session rules, policy-gap categories, and dangerous auto-approve state into one operator-facing summary
- the `Current Session State` panel now also shows a `Session Risk` badge (`none`, `low`, `medium`, `high`, `critical`) so operators can see the current overall relay risk posture without opening the detailed risk summary
- basic desktop operator settings now persist across restarts in `%LocalAppData%\\RelayAppMvp\\ui-settings.json`, including working directory, initial prompt, session id draft, runtime mode, and dangerous auto-approve mode
- the desktop state summary now explicitly shows that Codex approval is broker-routed while Claude approval remains audit-only in the current `stream-json` product path
- crash logging for startup/runtime failures under `%LocalAppData%\RelayAppMvp\relayapp-crash-*.log`
- real CLI adapter scaffolds for Codex and Claude
- prompt wrapping that forces Codex and Claude CLI turns to end in a single handoff JSON object

Not implemented yet:

- robust approval handling
- native session recovery after app restart
- adapter-specific structured diagnostics in the UI
  - the broker intentionally drops native handles after restart today to protect accounting integrity; true crash-safe native session recovery is still not implemented
  - Codex cost currently uses a local estimate rather than a vendor-emitted USD field
  - Codex cost is only as accurate as the locally discoverable model configuration and local rate card; if the model cannot be resolved or the rate card does not recognize it, the app falls back to the default rate card and logs that fallback in diagnostics
  - the UI now shows both side-specific estimated subtotals, a computed mixed total, and the Claude ceiling activation state (`active`, `inactive`, or `awaiting auth signal`):
    Claude cost is CLI-estimated and not billing-authoritative, while Codex cost remains a local rate-card estimate from the stamped rate card

## Operating model

This MVP is a bounded turn relay, not a long-running shared-agent runtime.

- Each side is expected to produce one handoff per turn.
- State continuity is carried primarily by the handoff packet, not by unlimited hidden chat history.
- Claude currently uses `-p` plus session resume.
- Codex currently uses `exec` plus session resume.
- The app treats long-lived hidden context as unreliable and expensive, so it prefers explicit relay state over implicit conversational memory.
- Bounded runtime remains the trust and cost baseline even while protocol-first interactive transport is explored.
- Interactive must eventually prove cost, latency, and stability parity before it can replace bounded mode as the default.
- Current prototype work now wires live usage telemetry into broker state and includes first circuit breakers for cumulative output growth, Claude-side repeated low-cache turns, planned turn-count / wall-clock rotation, live session-cost capture (Claude CLI-estimated, Codex estimated from token usage), normalized Codex cached-input accounting, corrected Codex app-server token extraction, cache-regression rotation, and bounded fallback retry when a budget trip happens inside the interactive runtime. When fallback usage is exposed by the bounded CLI, the broker now adds it to cumulative totals instead of treating the retry as free, converts cumulative Codex thread totals into delta usage before accumulation, keeps fallback turns out of the interactive cache-regression signal, and wraps desktop CLI process launches in Windows Job Objects through a suspended-create path with job-level CPU-time, process-count, memory, and kill-on-close limits for stronger cleanup. Process recycling is still not implemented.
- Current prototype work now wires live usage telemetry into broker state and includes first circuit breakers for cumulative output growth, Claude-side repeated low-cache turns, planned turn-count / wall-clock rotation, live session-cost capture (Claude CLI-estimated, Codex estimated from token usage), normalized Codex cached-input accounting, corrected Codex app-server token extraction, cache-regression rotation, bounded fallback retry when a budget trip happens inside the interactive runtime, and a broker-level per-turn wall-clock timeout. When fallback usage is exposed by the bounded CLI, the broker now adds it to cumulative totals instead of treating the retry as free, converts cumulative Codex thread totals into delta usage before accumulation, keeps fallback turns out of the interactive cache-regression signal, and wraps desktop CLI process launches in Windows Job Objects through a suspended-create path with job-level CPU-time, process-count, memory, and kill-on-close limits for stronger cleanup. Process recycling is still not implemented.

Why this matters:

- `-p` or `exec` style calls are weaker than a rich interactive session for long tool chains and deep rolling context.
- Keeping one session alive forever increases token cost and drift risk.
- This MVP therefore optimizes for bounded relay turns, explicit prompt passing, diagnostics, and repairability rather than uninterrupted autonomous reasoning.

Recommended usage pattern:

- Use `Smoke Test 2` first.
- Use short, explicit prompts.
- Use `Advance Once` until the relay is stable.
- Treat the handoff JSON as the source of truth.
- Avoid assuming that one side will remember broad prior context unless that context is restated in the handoff prompt.

Next-phase design:

- [INTERACTIVE-REBUILD-PLAN.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\INTERACTIVE-REBUILD-PLAN.md)
- [IMPROVEMENT-PLAN.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\IMPROVEMENT-PLAN.md)
- [PHASE-A-SPEC.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\PHASE-A-SPEC.md)
- [CLAUDE-APPROVAL-DECISION.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\CLAUDE-APPROVAL-DECISION.md)
- [EXTERNAL-REVIEW-PROMPT.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\EXTERNAL-REVIEW-PROMPT.md)
- [TESTING-CHECKLIST.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\TESTING-CHECKLIST.md)
- [mcp-audit.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\mcp-audit.md)
- [shell-audit.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\shell-audit.md)
- [capability-matrix.md](D:\dad-v2-system-template\prototypes\relay-app-mvp\capability-matrix.md)
- `RelayApp.Desktop\Interactive\*` now mixes two experimental transport adapters:
  - `CodexInteractiveAdapter` uses `codex app-server`
  - `ClaudeInteractiveAdapter` uses `claude -p --output-format stream-json --verbose`
- both adapters are still experimental and currently run one turn at a time
- the old redirected-stdio interactive prototype has been removed from the active codebase
- the bounded runtime now uses the same `===DAD_HANDOFF_START===` / `===DAD_HANDOFF_END===` marker contract as the interactive runtime, so bounded turns can do limited exploration or tool use before emitting the final handoff block instead of being forced into raw-JSON-only output
- The current plan now favors a protocol-first hybrid interactive runtime:
  - Claude via structured streaming or SDK surface
  - Codex via app-server / JSON-RPC surface
  - broker-managed compaction, rotation, and carry-forward state instead of TUI-dependent auto-compaction
  - bounded runtime as the only fallback
  - transport-side session IDs and resume handles treated as hints, not as the continuity source of truth
  - live transport usage fields treated as the only in-session cost source; Claude's USD comes from the CLI's own estimate, not a billing-console reading

## Run

```powershell
dotnet build .\RelayApp.Desktop\RelayApp.Desktop.csproj -p:UseSharedCompilation=false
dotnet run --project .\RelayApp.Desktop\RelayApp.Desktop.csproj
```

## Codex Protocol Spike

The repo now includes a reusable Codex protocol library plus a minimal spike runner:

- [RelayApp.CodexProtocol](D:\dad-v2-system-template\prototypes\relay-app-mvp\RelayApp.CodexProtocol)
- [RelayApp.CodexProtocol.Spike](D:\dad-v2-system-template\prototypes\relay-app-mvp\RelayApp.CodexProtocol.Spike)

Purpose:

- launch `codex app-server --listen stdio://`
- send `initialize`
- send `getAuthStatus`
- send `thread/start`
- send `turn/start`
- capture protocol messages in a reusable library
- expose one-shot turn execution data including final agent text and token-usage notifications

Run it like this:

```powershell
dotnet run --project .\RelayApp.CodexProtocol.Spike\RelayApp.CodexProtocol.Spike.csproj -- D:\dad-relay-mvp-temp
```

Current known behavior from the spike:

- the protocol handshake works on this machine
- thread and turn lifecycle events arrive over stdio JSONL
- token usage events are exposed directly
- the reusable library can now run a one-shot turn and recover the final `agentMessage` text
- plugin sync warnings may appear on stderr, but the protocol still works

## How to use

1. Confirm both CLIs work in the same shell:
   - `codex --version`
   - `claude --help`
2. Authenticate both tools before launching the app.
3. For Claude Pro/Max users, prefer a long-lived subscription token for headless use:
   ```powershell
   claude setup-token
   ```
   After browser authorization, Claude prints a one-year token to the terminal. Copy it immediately because the command does not save it for you.
4. Set the token in your environment:
   ```powershell
   # current shell
   $env:CLAUDE_CODE_OAUTH_TOKEN = "sk-ant-oat01-..."

   # persistent user-level setting
   [System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_OAUTH_TOKEN", "sk-ant-oat01-...", "User")
   ```
5. Verify Claude headless mode before opening the relay app:
   ```powershell
   claude -p "Return exactly the word ok." --output-format json
   ```
6. If you need to inspect the short-lived cached OAuth state used by `/login`, it lives here on Windows:
   ```powershell
   Get-Content "$env:USERPROFILE\.claude\.credentials.json"
   ```
   The `claudeAiOauth` object contains `accessToken`, `refreshToken`, and `expiresAt`. This cached token is less stable for long-running automation than the one-year token from `claude setup-token`.
7. Set `Working Directory` to the repository both sides should operate on.
8. Optionally enable `Use interactive adapters (experimental; current prototype only)` if you want to inspect the old prototype path.
   Today that means:
   - Claude can use the stream-json experimental adapter.
   - Codex can use the protocol-backed experimental adapter via `codex app-server`.
   - both sides still run one turn at a time and do not yet preserve long-lived interactive continuity in this mode.
   This is not the planned production architecture.
9. Click `Check Adapters`.
10. Confirm the `Adapter Status` panel shows both sides as reachable.
    `Check Adapters` runs a real headless probe for both Claude and Codex. It is intentionally stricter than checking only `auth status` or `--version`.
11. Optionally click `Smoke Test 2` first.
    This creates a temporary transport-only smoke session, asks each side for a minimal relay handoff, and pauses automatically if both turns succeed.
12. Enter a session id and initial prompt, then click `Start Session`.
    If any real adapter is still unhealthy, the app blocks session start and shows the reason in the status area.
13. Use `Advance Once` for the first real relay. Only use `Auto Run 4` after the first turn succeeds cleanly.
14. For first live tests, prefer the temp workspace `D:\dad-relay-mvp-temp` instead of a real project repository.
15. Keep initial prompts narrow. Ask for one concrete next handoff, not an open-ended autonomous workstream.
16. If you need broad context, put it in the prompt or in files the agents can read from the working directory. Do not assume `-p` style continuity alone will carry it.
17. If the window closes immediately during startup, inspect `%LocalAppData%\RelayAppMvp\relayapp-crash-*.log`.
18. If you want continuously updated readable logs while the app runs, open `%LocalAppData%\RelayAppMvp\auto-logs`.
    - `current-status.txt` is the latest overall snapshot
    - `session-<session-id>-status.txt` is the latest snapshot for the active session
    - `latest-handoff.json` is the latest accepted handoff shown in the UI
    - `%LocalAppData%\RelayAppMvp\logs\*.jsonl` remains the append-only event log
19. If the window is narrow, the action buttons wrap onto multiple lines and the whole window can scroll vertically.
20. Optional advanced tuning lives at `%LocalAppData%\RelayAppMvp\broker.json`.
    - property names are case-insensitive
    - comments and trailing commas are accepted
    - unknown property names are rejected with a visible warning instead of being ignored
    - malformed files fall back to built-in defaults with a visible warning
    - out-of-range values are clamped back to safe defaults with a visible warning
    - `MaxClaudeCostUsd` is a per-session-segment Claude ceiling and only activates when Claude reports api-key auth; other auth modes leave the ceiling inactive and produce a segment-scoped advisory event

## Runtime modes

- Default runtime:
  Claude uses `claude -p --output-format json` and resumes by session id.
  Codex uses `codex exec --json -o <tempfile>` for first turn and `codex exec resume ... --json -o <tempfile>` for resumed turns.
  Both bounded adapters now expect the final handoff inside the standard marker block rather than relying on raw JSON as the only visible output shape.
- Experimental runtime:
  The UI can switch to interactive adapters for architecture validation.
  The current implementation is mixed but protocol-first:
  - Codex uses a protocol-backed experimental adapter built on `codex app-server`
  - Claude uses a structured streaming experimental adapter built on `claude -p --output-format stream-json --verbose`
  - both still run one turn at a time instead of preserving a true long-lived session
  The next design direction is protocol-first hybrid interactive:
  - Codex via app-server / JSON-RPC
  - Claude via structured streaming or SDK
  - bounded runtime as fallback

The default runtime is the only path that has completed repeated smoke tests.
The interactive runtime exists for next-stage validation and should still be treated as experimental.

Known constraints:

- Claude `/login` state can report logged-in while headless `-p` still fails. The app now treats a real probe request as the source of truth during `Check Adapters`.
- `CLAUDE_CODE_OAUTH_TOKEN` is the preferred subscription-safe path for headless scripts in this app. The relay app uses standard `claude -p` mode, not `--bare`.
- Codex `--json` mode can emit noisy stderr even when the probe succeeds. The app does not fail readiness on warnings alone.
- The smoke test is a transport compliance check, not a real repository work turn.
- The relay architecture favors explicit handoff packets over deep hidden context. This is safer for reproducibility, but weaker for long uninterrupted reasoning.
- The relay does not trust TUI auto-compaction as a safety boundary. Compaction and rotation are expected to be broker-managed.
- The interactive plan does not treat TUI auto-compaction as a dependency. The broker is expected to own rotation, carry-forward summaries, and budget ceilings.
- Resume/session continuity on vendor transports is treated as an optimization, not a contract. The authoritative continuity record is the accepted handoff chain plus broker state.
- Interactive runtime must eventually satisfy both token-cost ceilings and rotation-latency ceilings. Cheap but slow rotation, or fast but runaway resume growth, are both considered failures.
- Input budgets alone are not sufficient. Output/thinking-token growth and cache regressions must also trigger rotation or downgrade.
- Local CLI history logs are not treated as authoritative budget sources. The plan expects cost accounting to come from live structured usage events.
- Long-lived transport processes, especially `codex app-server` on Windows, must eventually be recycled on a schedule instead of being trusted to run forever.
- Codex can still emit prose on the first turn. The MVP now recovers via repair, normalization, and smoke-test synthesis, but that is still a mitigation rather than perfect compliance.
- The interactive runtime currently implemented in the app is only partially on the target architecture. Codex uses `app-server`, and Claude uses `stream-json`, but both still behave as one-turn experimental transports rather than true long-lived sessions.
- The real next-step architecture is not PTY-first. It is protocol-first hybrid interactive.
- The broker currently supports one active session at a time.

## Verified locally

- `dotnet build .\RelayApp.Core\RelayApp.Core.csproj -p:UseSharedCompilation=false`
- `dotnet build .\RelayApp.Desktop\RelayApp.Desktop.csproj -p:UseSharedCompilation=false`
