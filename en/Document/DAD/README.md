# DAD Reference Docs

Detailed DAD protocol references live here instead of staying in one monolithic root contract.

## Why These Files Are Split

- Agent harnesses and file-reading tools can hit token or file-size limits on large Markdown files.
- Root contract files such as `DIALOGUE-PROTOCOL.md` are frequently read first, so they should stay readable in one call.
- Detailed schema tables, validation checklists, and prompt reference lists drift less when they are isolated in smaller files.

## Maintenance Rule

- Keep root contract docs thin and authoritative.
- Move detailed schema, lifecycle, and validation rules into focused reference files under `Document/DAD/`.
- If one of these reference files becomes too large to read comfortably in one pass, split it again by topic instead of letting it grow into another monolith.

## Reference Map

- `PACKET-SCHEMA.md`
- `STATE-AND-LIFECYCLE.md`
- `VALIDATION-AND-PROMPTS.md`
