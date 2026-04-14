---
name: dadtpl-dialogue-start
description: "Explicit-invocation skill to start a DAD v2 symmetric-turn dialogue session with Claude Code. Use when directly invoked via `$dadtpl-dialogue-start`. Use when an external critical review is valuable for medium/large tasks. Do not use for small tasks that a single agent can handle. Triggers: \"start dialogue session\", \"dialogue start\", \"collaborate with Claude Code\"."
---

# Dialogue Start (Codex takes Turn 1)

DAD v2 session start where Codex (this agent) performs Turn 1 and produces a Claude Code prompt.

## Invocation

- This skill is **explicit-invocation only**, not auto-suggested.
- Example: `Start a DAD v2 session via $dadtpl-dialogue-start.`

## Preconditions

- The agent running this skill acts as **Codex**.
- The contract file is `AGENTS.md` (Claude Code's is `CLAUDE.md`).
- When producing the peer (Claude Code) prompt, start with `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`

## Procedure

1. Read `PROJECT-RULES.md` first, then read `AGENTS.md` and `DIALOGUE-PROTOCOL.md` to internalize the v2 protocol. If `DIALOGUE-PROTOCOL.md` points to `Document/DAD/` references, read the needed files there too.
2. Analyze the current project state:
   - `git log --oneline -10` (recent work flow)
   - `git status` (current changes)
   - Check recent failing tests, CI records, or local verification logs if available
   - Check repo-specific research / inventory / architecture docs if present
3. Judge task scope (small / medium / large).
4. **Execute Turn 1**:
   a. For large scope → build `task_model` (goals / non-goals / risks / success shape)
   b. Draft the Sprint Contract (for medium/large):
      - Concrete checkpoint list (including verification methods)
      - `reference_prompts` links
   c. Plan + execution
   d. Self-iteration loop: self-verify until all Contract checkpoints pass, repeat until satisfied
   e. Save the Turn Packet as `Document/dialogue/sessions/{session-id}/turn-01.yaml`
5. Initialize/update `Document/dialogue/state.json`:
   - `protocol_version: "dad-v2"`
   - `relay_mode: "user-bridged"`
   - `last_agent: "codex"` (Turn 1 starter)
6. Output a Claude Code-facing prompt to the user (prompt body only, no CLI wrapper).
   The prompt must include these 6 elements:
   - `Read PROJECT-RULES.md first. Then read CLAUDE.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
   - `Session: Document/dialogue/state.json`
   - `Previous turn: Document/dialogue/sessions/{session-id}/turn-01.yaml`
   - Concrete task instruction (`handoff.next_task + handoff.context`)
   - A ~10-line relay-friendly summary
   - The mandatory tail block below
   Append this tail block at the end of the prompt:

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```

## Branch Rules

- No direct push to main. If on main when starting the session, create a new task branch.
- Convergence commits also go on the task branch → push → PR → merge to main.

## Session Modes

- **Autonomous**: only ESCALATE reaches the user; everything else auto.
- **Supervised**: user confirmation required for every convergence.
- **Hybrid** (default): confirmation only when scope is large or confidence is low.
