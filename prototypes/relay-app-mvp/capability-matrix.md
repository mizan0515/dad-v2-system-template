# Capability Matrix

Audit date: 2026-04-17

This matrix records what is confirmed locally, what is conditional, and what is still pending audit.

## Current Status

| Area | Codex | Claude | Relay/Broker status | Evidence |
|---|---|---|---|---|
| Bounded turn handoff | Working | Working | Working | existing smoke path + current desktop default runtime |
| Interactive transport | Working (app-server one-turn) | Working (stream-json one-turn) | Experimental | existing prototype implementation |
| Broker-routed approval | Working | No | Asymmetric by design | `CLAUDE-APPROVAL-DECISION.md` |
| Command/git policy | Working | Audit-only | Working for Codex approval path | current `RelayApprovalPolicy.cs` |
| MCP config discovery | Working | Conditional | Partial | `mcp-audit.md` |
| MCP tool call execution | Working | Conditional | Partial | `mcp-audit.md` |
| MCP action classification | Working | Working | Working | `mcp-audit.md` + current policy/adapters |
| MCP review bridge and low-risk defaults | Working | Working | Working | `mcp-audit.md` + current broker policy |
| MCP pre-execution broker approval | No | No | Not implemented | current product gap |
| Shell/PowerShell audit | Working | Working | Partial | `shell-audit.md` |
| Git audit (read-only) | Working | Working | Partial | `git-audit.md` |
| Git audit (destructive / push / PR) | Working (add/commit/push) | Pending live | Partial | `git-audit.md` destructive-tier section; session `destructive-qa-20260417-131500`; PR live exercise still pending |
| Git category classification on Windows | Working | Working | Working | verified live in QA session `git-classify-qa-20260417-115929`; `RelayApprovalPolicy.ClassifyCommandCategory` now unwraps `powershell`/`pwsh`/`cmd /c` wrappers and strips `git -c`/`-C` option pairs; Codex adapter refines `commandExecution` items into the specific git class |
| DAD asset classification | Working (writes) / Working (pure reads) | Pending live | Working | `dad-asset-audit.md`; session `dad-asset-qa-20260417-145500`; iteration-8 classifier adds `read` category for pure `Get-Content`/`cat`/`type` verified in session `read-classify-qa-20260417-180000` |
| Read category classification | Working | Working | Working | session `read-classify-qa-20260417-180000` — pure `Get-Content 'path'` routed to `read.requested`/`.completed`; piped/scripted compound PowerShell correctly stays `shell` |
| Codex Windows compatibility matrix | Working | n/a | Working | `codex-windows-matrix.md` — consolidated from shell/git/MCP/DAD live sessions |

## Interpretation

### Working

- feature is confirmed locally with real commands or existing relay smoke coverage

### Conditional

- feature works only when workspace configuration or external runtime state is present

### Partial

- the relay can observe and govern part of the feature, but not the full desired product behavior yet

## Next Audit Priorities

1. ~~Shell/PowerShell audit~~ (done)
2. ~~Git audit (read-only)~~ (done)
3. ~~Git audit — live destructive add/commit/push end-to-end~~ (done — `gh pr create` live exercise still pending, blocked on real remote)
4. ~~Fix Codex/Windows PowerShell-wrapping classifier gap~~ (done)
5. ~~Honour `AutoApproveAllRequests` for server-originated `item/commandExecution/requestApproval` events in the Codex interactive transport~~ (done — adapter now resolves auto-approve synchronously and emits the correct `accept` decision)
6. ~~DAD asset classification~~ (done — partial: writes classified via `file-change`, reads collapse into `shell` on Codex/Windows because reads are wrapped as `powershell.exe -Command "Get-Content …"`)
7. Add a dedicated DAD-asset band in `RelayApprovalPolicy` (surfaced by `dad-asset-audit.md`) so writes under `Document/dialogue/**` (backlog/state/sessions) are distinguishable from arbitrary file changes
8. ~~Extend `ClassifyCommandCategory` to recognise `Get-Content`/`cat`/`type <path>` inside unwrapped PowerShell payloads so DAD-asset reads are not indistinguishable from arbitrary shell~~ (done — `read` category added and auto-allowed; compound/piped commands correctly remain `shell`)
9. ~~Codex Windows compatibility matrix~~ (done — see `codex-windows-matrix.md`)
10. Git sh.exe / msys pipe-creation failure under the relay's Job Object sandbox (surfaced by the auto-approve push QA — non-blocking for approval flow, but a real Windows compatibility gap)
