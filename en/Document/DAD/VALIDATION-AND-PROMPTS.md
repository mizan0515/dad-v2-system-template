# DAD Validation And Prompt References

Use this file for validation timing, peer prompt rules, and prompt references.

## Peer Prompt Rules

Every peer prompt must include:

1. `Read PROJECT-RULES.md first. Then read {agent-contract}.md and DIALOGUE-PROTOCOL.md. If that file points to Document/DAD references, read the needed files there too.`
2. `Session: Document/dialogue/state.json`
3. `Previous turn: Document/dialogue/sessions/{session-id}/turn-{N}.yaml`
4. concrete `handoff.next_task + handoff.context`
5. a relay-friendly summary
6. the mandatory tail block
7. the exact prompt text saved to `handoff.prompt_artifact`, typically `Document/dialogue/sessions/{session-id}/turn-{N}-handoff.md`

Mandatory tail:

```
---
If you find any gap or improvement, fix it directly and report the diff.
If nothing needs to change, state explicitly: "No change needed, PASS".
Important: do not evaluate leniently. Never say "looks good". Cite concrete evidence and examples.
```

## Validation

Use:

- `tools/Validate-Documents.ps1 -Root . -IncludeRootGuides -IncludeAgentDocs -Fix`
- `tools/Validate-DadPacket.ps1 -Root . -AllSessions`

Run validation at minimum:

1. after saving a turn packet
2. after saving the handoff prompt artifact referenced by `handoff.prompt_artifact`
3. before recording `suggest_done: true`
4. before resuming a recovered session

## Prompt References

Base references in this template:

- `.prompts/01-system-audit.md`
- `.prompts/02-session-start-contract.md`
- `.prompts/03-turn-closeout-handoff.md`
- `.prompts/04-session-recovery-resume.md`
- `.prompts/05-debate-disagreement.md`
- `.prompts/06-convergence-pr-closeout.md`
- `.prompts/07-existing-project-migration.md`
- `.prompts/08-template-review-hardening.md`
- `.prompts/09-emergency-session-recovery.md`
- `.prompts/10-system-doc-sync.md`
- `.prompts/11-dad-operations-audit.md`

## Large-File Reading Rule

- If a required reference file is too large to read in one call, read the section index first, then read only the needed sections in chunks.
- Do not stop the task only because a monolithic read failed once.
- Prefer splitting large reference docs before adding more fallback wording to prompts.
