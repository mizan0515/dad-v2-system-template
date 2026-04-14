# Dual-Agent Dialogue Protocol (DAD v2)

Thin-root protocol for symmetric-turn collaboration between Codex and Claude Code.

Keep this root file readable in one call. Detailed schema, lifecycle, and validation rules live under `Document/DAD/`.

## Core Principles

1. Symmetric turns: both agents plan, execute, and evaluate.
2. Sprint Contract: done state is expressed as concrete checkpoints.
3. Self-iteration: each agent verifies its own work before handoff.
4. Live files first: repository reality beats stale memory.
5. Schema discipline: packets and state must validate.
6. System-doc sync: if DAD infra, validators, commands, prompt templates, or agent contracts change, sync the related docs in the same task or make that the first next task.

## Turn Flow

- Turn 1: analyze state, draft contract, execute first slice, self-iterate, write packet, output peer prompt.
- Turn 2+: review the peer turn against checkpoints, execute your own slice, self-iterate, write packet, output peer prompt.

## Mandatory Rules

- `my_work` is mandatory.
- `suggest_done` and `done_reason` live only under `handoff`.
- If `suggest_done: true`, `done_reason` is required.
- Closed sessions require summary artifacts.
- Root `Document/dialogue/state.json` tracks the currently active session only.
- Prefer short, session-scoped slices over one long umbrella session when the goal or verification surface changes materially.
- If a new session replaces the current one, mark the previous session `superseded` or otherwise closed explicitly before moving on.

## Peer Prompt Rules

Every peer prompt must include:

1. `Read PROJECT-RULES.md first. Then read {agent-contract}.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. concrete `handoff.next_task + handoff.context`
5. a relay-friendly summary
6. the mandatory tail block
7. the same prompt text saved to `handoff.prompt_artifact`

Mandatory tail:

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```

## Validation

- `tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

Run validation at minimum:

1. after saving a turn packet
2. after saving the prompt artifact referenced by `handoff.prompt_artifact`
3. before recording `suggest_done: true`
4. before resuming a recovered session

## Detailed References

- `Document/DAD/README.md`
- `Document/DAD/PACKET-SCHEMA.md`
- `Document/DAD/STATE-AND-LIFECYCLE.md`
- `Document/DAD/VALIDATION-AND-PROMPTS.md`
