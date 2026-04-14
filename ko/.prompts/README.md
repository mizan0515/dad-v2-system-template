# .prompts

Prompt library for the reusable DAD v2 template.

## Included Prompts

| File | Purpose |
|------|---------|
| `01-시스템-감사.md` | Generic repository/system audit prompt |
| `02-세션-시작-컨트랙트-작성.md` | New session kickoff and contract drafting |
| `03-턴-종료-핸드오프-정리.md` | Turn closeout, packet, and handoff cleanup |
| `04-세션-복구-재개.md` | Session recovery and safe resume |
| `05-의견차이-디베이트-정리.md` | Debate and disagreement handling |
| `06-수렴-종료-PR-정리.md` | Convergence closeout, summary, branch, and PR checklist |
| `07-기존-프로젝트-도입-마이그레이션.md` | Introduce DAD v2 into an existing repository safely |
| `08-템플릿-검토-개선.md` | Review and harden the template itself before reuse |
| `09-비상-세션-복구.md` | Force-close and manually recover a broken DAD session safely |
| `10-시스템-문서-정합성-동기화.md` | System-doc / validator / command sync prompt |

## Usage

- Use `01-시스템-감사.md` when auditing a new repository or checking whether the DAD system is coherent after changes.
- Use `02-세션-시작-컨트랙트-작성.md` when creating Turn 1 and drafting the initial contract.
- Use `03-턴-종료-핸드오프-정리.md` before finalizing any turn packet and peer prompt.
- Use `04-세션-복구-재개.md` when resuming a paused or interrupted session.
- Use `05-의견차이-디베이트-정리.md` when peer verdicts diverge on the same checkpoint.
- Use `06-수렴-종료-PR-정리.md` when both agents are near done and you need to close the session without skipping summaries, validation, branch hygiene, or PR steps.
- Use `07-기존-프로젝트-도입-마이그레이션.md` before enabling DAD v2 in a repository that already has its own rules, commands, or automation.
- Use `08-템플릿-검토-개선.md` when Claude Code should audit and improve the template repository itself.
- Use `09-비상-세션-복구.md` when `state.json`, turn packets, or validators are broken enough that normal resume flow is unsafe.
- Use `10-시스템-문서-정합성-동기화.md` whenever a task changes protocol docs, validators, session schema, slash commands, skills, or prompt templates.
- Add project-specific prompts here as the target repository grows.
