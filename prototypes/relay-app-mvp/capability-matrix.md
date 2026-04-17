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
| Git audit (destructive / push / PR) | Pending live | Pending live | Partial | `git-audit.md` (policy verified, live end-to-end pending) |
| Git category classification on Windows | Pending fix | Working | Gap | `git-audit.md` — Codex PowerShell-wrapping prevents `git*` classification |
| DAD asset classification | Pending | Pending | Pending | not yet captured in dedicated audit doc |
| Codex Windows compatibility matrix | Pending | n/a | Pending | not yet captured in dedicated audit doc |

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
3. Git audit — live destructive / push / PR end-to-end
4. Fix Codex/Windows PowerShell-wrapping classifier gap
5. DAD asset classification
6. Codex Windows compatibility matrix
