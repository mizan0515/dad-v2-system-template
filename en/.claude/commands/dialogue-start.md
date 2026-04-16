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
3. Judge whether the proposed session is outcome-scoped. If the work is only wording correction, state/summary sync, closure seal, or validator-noise cleanup, fold it into the active execution session unless you are explicitly repairing broken DAD state or packet/schema drift.
4. Judge task scope (small / medium / large).
5. If `Document/dialogue/state.json` already points to an active session, do not silently open a second one. Continue the active session with `/repeat-workflow`, or supersede/repair the linkage explicitly first.
6. Create the session through `tools/New-DadSession.ps1` and make sure it links exactly one backlog item in `Document/dialogue/backlog.json`. Auto-bootstrap is only for fresh work when no reusable `now` or equivalent queued candidate already exists.
7. **Execute Turn 1**:
   a. Draft the Sprint Contract (for medium/large):
      - Concrete checkpoint list (including verification methods)
      - `reference_prompts` links
      - At least one checkpoint naming the concrete artifact, verified decision, or risk disposition that justifies opening the session
   b. Plan + partial execution
   c. Self-iteration loop: self-verify against checkpoints, repeat until satisfied
   d. Save the Turn Packet as `Document/dialogue/sessions/{session-id}/turn-01.yaml`
8. Initialize/update `Document/dialogue/state.json`.
9. If another peer turn remains, use a handoff only for outcome work. Keep `handoff.next_task` for current-session continuation; if newly discovered work needs a different future session, record it in `Document/dialogue/backlog.json` instead. Do not generate a verify-only / wording-only / sync-only / seal-only follow-up unless the remaining work is risk-gated or the DAD system itself needs repair.
10. Set `handoff.closeout_kind: peer_handoff`, save the exact Codex-facing prompt to `Document/dialogue/sessions/{session-id}/turn-01-handoff.md`, record that path in `handoff.prompt_artifact`, and set `handoff.ready_for_peer_verification: true` only after `handoff.next_task`, `handoff.context`, and `handoff.prompt_artifact` are all final.
11. Output the same Codex-facing prompt to the user in the same final reply that closes Turn 1 (prompt body only, no CLI wrapper). Do not stop at a status summary and wait for the user to ask for the next prompt.
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
