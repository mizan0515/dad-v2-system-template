---
description: Judgment-light Dual-Agent Dialogue v2 symmetric turns (minimal user confirmation, user relay still required)
argument-hint: "[turn count, default 5]"
---

# /repeat-workflow-auto

The **judgment-light variant** of `/repeat-workflow`. Decides automatically even in
ambiguous situations without asking the user. Only ESCALATE reaches the user.

Note: DAD v2 is a **user-bridged protocol**. This command cannot hide the peer-agent
invocation itself. What is automated is the judgment and convergence rules, not the
user relay step.

Use `/repeat-workflow N` when supervision is needed.

## Arguments
- `$ARGUMENTS` = number of turns to repeat (1–10). Defaults to 5 if empty.

## Differences vs `/repeat-workflow` (4 overrides)

1. **Minimal user confirmation** — automatic judgment except ESCALATE
2. **Autonomous task selection** — picks the highest-value task from analysis
3. **Automatic PASS convergence** — on full checkpoint pass, auto-finish the closeout. If this is the final converged turn, complete summary/state plus task-branch commit + push + PR in the same turn unless a concrete blocker prevents it.
4. **Auto-pivot on stagnation** — if the same checkpoint FAILs twice consecutively, auto-switch approach

## Procedure

1. Read `PROJECT-RULES.md` first, then read `CLAUDE.md` and `DIALOGUE-PROTOCOL.md`. If `DIALOGUE-PROTOCOL.md` points to `Document/DAD/` references, read the needed files there too.
2. Check existing session state in `Document/dialogue/state.json` (if absent, start a new session with `/dialogue-start`).
3. Automatically analyze current project state (git log, tests, console)
4. Autonomously execute `$ARGUMENTS` (or 5) turns:
   - Auto-generate Contract → execute work → self-iterate → save peer prompt artifact → generate peer prompt when another turn remains (including mandatory tail) → user relay → next-turn or final-turn convergence decision
   - Save Turn Packet as `Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
   - Save the exact peer prompt to `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`, record that path in `handoff.prompt_artifact`, and leave `handoff.ready_for_peer_verification` false until `handoff.next_task` and `handoff.context` are final.
   - The peer prompt must include these 7 elements:
     - `Read PROJECT-RULES.md first. Then read AGENTS.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
     - `Session: Document/dialogue/state.json`
     - `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
     - Concrete task instruction (`handoff.next_task + handoff.context`)
     - A ~10-line relay-friendly summary
     - The mandatory tail block below
     - The exact same body saved in `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`
   - Append this tail block at the end of the peer prompt:
     ```
     ---
     If you find any gap or improvement, fix it directly and report the diff.
     If nothing needs to change, state explicitly: "No change needed, PASS".
     Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
     ```
5. On finish, record the session summary under `Document/dialogue/sessions/{session-id}/`

## Safety Guards

1. Hard turn limit: stop immediately when exceeded
2. Three consecutive FAILs on the same checkpoint → auto-stop + report to user
3. Unresolvable compile error → stop + report to user
4. No direct push to main branch
5. Two consecutive turns of quality stagnation → auto-pivot to a different approach
