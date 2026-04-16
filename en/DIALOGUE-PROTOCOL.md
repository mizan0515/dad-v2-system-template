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
7. Outcome over ceremony: each session should drive a concrete artifact, verified decision, or explicit risk disposition.

## Turn Flow

- Turn 1: analyze state, draft contract, execute first slice, self-iterate, write packet, and output the peer prompt in the same reply that closes the turn.
- Turn 2+: review the peer turn against checkpoints, execute your own slice, self-iterate, then either write packet + output the next peer prompt in the same closeout reply or, on the final converged turn, write the closeout packet and finish session closeout.

## Mandatory Rules

- `my_work` is mandatory.
- `suggest_done` and `done_reason` live only under `handoff`.
- If `suggest_done: true`, `done_reason` is required.
- Closed sessions require summary artifacts.
- A converged final turn with verified changes still owes repository closeout. If no peer handoff remains, finish commit/push/PR in that same turn unless `PROJECT-RULES.md` explicitly allows otherwise; if blocked, record the blocker concretely.
- Root `Document/dialogue/state.json` tracks the currently active session only.
- `Document/dialogue/backlog.json` is the admission layer for future session candidates. Current-session continuation still belongs in `handoff.next_task`, not in backlog churn.
- Open or continue a session only when it is driving a concrete outcome such as a code change, measurement artifact, smoke result, config/runtime decision, or explicit risk disposition.
- Do not open a new session whose only goal is wording correction, state/summary sync, closure seal, or validator-noise cleanup; fold those into the active work session unless you are explicitly repairing broken DAD state or packet/schema drift.
- Peer verification is risk-gated, not automatic. Use a verify-only relay only for remote-visible mutation, config/runtime decisions, high-risk measurements, destructive cleanup, or provenance/compliance-sensitive work.
- Summary/state sync, closure confirmation, and final wording cleanup belong in the same execution turn's closeout, not a separate post-closeout session.
- Prefer short, session-scoped slices over one long umbrella session when the goal or verification surface changes materially.
- If a new session replaces the current one, mark the previous session `superseded` or otherwise closed explicitly before moving on.

## Peer Prompt Rules

Apply these rules when another peer turn remains. A final converged turn may end without a new peer prompt, but it still must complete summary/state closeout and the git closeout required by `PROJECT-RULES.md`.

When another peer turn remains, every peer prompt must include:

1. `Read PROJECT-RULES.md first. Then read {agent-contract}.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. concrete `handoff.next_task + handoff.context`
5. a relay-friendly summary
6. the mandatory tail block
7. the same prompt text saved to `handoff.prompt_artifact`

In `user-bridged` mode, saving the artifact is not enough. The same closeout reply must also paste the exact relay prompt. Do not defer it until the user asks for "the next prompt."

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
- `tools/Validate-DadBacklog.ps1 -Root .`

Run validation at minimum:

1. after saving a turn packet
2. after saving the prompt artifact referenced by `handoff.prompt_artifact`, when that turn actually emits a peer handoff
3. before recording `suggest_done: true`
4. before resuming a recovered session
5. after backlog linkage changes or before closing a linked session

## Detailed References

- `Document/DAD/README.md`
- `Document/DAD/PACKET-SCHEMA.md`
- `Document/DAD/STATE-AND-LIFECYCLE.md`
- `Document/DAD/BACKLOG-AND-ADMISSION.md`
- `Document/DAD/VALIDATION-AND-PROMPTS.md`
