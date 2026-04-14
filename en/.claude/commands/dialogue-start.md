---
description: Start a Dual-Agent Dialogue v2 session with Codex (symmetric turns)
argument-hint: "[task description]"
---

# /dialogue-start

Start a symmetric-turn Dialogue session between Codex and Claude Code.

## Arguments

- `$ARGUMENTS` = task description (one line). If empty, analyze project state and auto-suggest.

## Procedure

1. Read `PROJECT-RULES.md` first, then read `CLAUDE.md` and `DIALOGUE-PROTOCOL.md` to internalize the v2 protocol. If `DIALOGUE-PROTOCOL.md` points to `Document/DAD/` references, read the needed files there too.
2. Analyze the current project state:
   - `git log --oneline -10` (recent work flow)
   - `git status` (current changes)
   - Check recent failing tests, CI records, or local verification logs if available
   - Check repo-specific research / inventory / architecture docs if present
   - For repos that handle runtime, editor, or service logs, check related error logs
3. Judge task scope (small / medium / large).
4. **Execute Turn 1**:
   a. Draft the Sprint Contract (for medium/large):
      - Concrete checkpoint list (including verification methods)
      - `reference_prompts` links
   b. Plan + partial execution
   c. Self-iteration loop: self-verify against checkpoints, repeat until satisfied
   d. Save the Turn Packet as `Document/dialogue/sessions/{session-id}/turn-01.yaml`
5. Initialize/update `Document/dialogue/state.json`.
6. Save the exact Codex-facing prompt to `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`, record that path in `handoff.prompt_artifact`, and set `handoff.ready_for_peer_verification: true` only after `handoff.next_task` and `handoff.context` are final.
7. Output the same Codex-facing prompt to the user (prompt body only, no CLI wrapper).
   The prompt must include these 7 elements:
   - `Read PROJECT-RULES.md first. Then read AGENTS.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
   - `Session: Document/dialogue/state.json`
   - `Previous turn: Document/dialogue/sessions/{session-id}/turn-01.yaml`
   - Concrete task instruction (`handoff.next_task + handoff.context`)
   - A ~10-line relay-friendly summary
   - The mandatory tail block below
   - The exact same body saved in `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`
   Append this tail block at the end of the prompt:
   ```
   ---
   If you find any gap or improvement, fix it directly and report the diff.
   If nothing needs to change, state explicitly: "No change needed, PASS".
   Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
   ```

## User Choice

Session mode can be selected:
- **Autonomous**: only ESCALATE reaches the user; everything else auto.
- **Supervised**: user confirmation required for every convergence.
- **Hybrid** (default): confirmation only when scope is large or confidence is low.

## Invocation Examples

```
/dialogue-start Fix the card-reward screen bug
/dialogue-start Code audit of the map system
/dialogue-start
```
