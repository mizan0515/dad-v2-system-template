---
name: repeat-workflow-auto
description: "Explicit-invocation skill for DAD v2 symmetric-turn autonomous-mode repetition. Use when directly invoked via `$repeat-workflow-auto`. Automates judgment; only ESCALATE reaches the user. Triggers: \"auto repeat\", \"autonomous mode\". Note: the user relay step is not automated."
---

# Repeat Workflow Auto (autonomous mode)

The **autonomous-mode variant** of `$repeat-workflow`. Decides automatically even in ambiguous situations without asking the user.

## Invocation

- This skill is **explicit-invocation only**, not auto-suggested.
- Example: `Continue the current DAD v2 session in autonomous mode via $repeat-workflow-auto.`
- If no session exists yet, call `$dialogue-start` first.

Note: DAD v2 is a **user-bridged protocol**. What is automated is the judgment and convergence rules, not the user relay step.

## Differences vs `$repeat-workflow` (4 overrides)

1. **Minimal user confirmation** — automatic judgment except ESCALATE
2. **Autonomous task selection** — picks the highest-value task from analysis
3. **Automatic PASS commit** — on full checkpoint pass, auto commit + push + PR on task branch (no direct push to main)
4. **Auto-pivot on stagnation** — if the same checkpoint FAILs twice consecutively, auto-switch approach

## Procedure

1. Read `PROJECT-RULES.md` first, then read `AGENTS.md` and `DIALOGUE-PROTOCOL.md`.
2. Check existing session state in `Document/dialogue/state.json` (if absent, call `$dialogue-start` first).
3. Automatically analyze the current project state (git log, tests, console).
4. Autonomous execution:
   - Auto-generate Contract → execute work → self-iterate → generate peer prompt → user relay → next-turn convergence decision
5. The peer prompt must include these 6 elements:
   - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md.`
   - `Session: Document/dialogue/state.json`
   - `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
   - Concrete task instruction (`handoff.next_task + handoff.context`)
   - A ~10-line relay-friendly summary
   - The mandatory tail block below
6. Append this tail block at the end of the peer prompt:
   ```
   ---
   If you find any gap or improvement, fix it directly and report the diff.
   If nothing needs to change, state explicitly: "No change needed, PASS".
   Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
   ```
7. On finish, record the session summary under `Document/dialogue/sessions/{session-id}/`.

## Safety Guards

1. Hard turn limit: stop immediately when exceeded
2. Three consecutive FAILs on the same checkpoint → auto-stop + report to user
3. Unresolvable compile error → stop + report to user
4. No direct push to main branch
5. Two consecutive turns of quality stagnation → auto-pivot to a different approach
