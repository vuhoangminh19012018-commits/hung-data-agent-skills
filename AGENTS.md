# AGENTS.md — Hung Data Agent Skills Repository

## Mission
Maintain a small, reusable set of Agent Skills for safe coding and data-mapping workflows.

## Working rules
- Read the relevant `skills/<name>/SKILL.md` before changing a skill.
- Keep each skill narrowly scoped and composable.
- Keep `SKILL.md` concise; move long detail into `references/` when needed.
- Do not copy large chunks from third-party skill repositories. Re-express ideas in original wording.
- Preserve the local-first constraint in `config/project-policy.md`.
- Run `python scripts/validate_skills.py` after any skill change.
- Before completion, show the validation result and `git diff --check` when inside a Git repo.

## Compatibility
Follow the open Agent Skills format: each skill directory must contain a valid `SKILL.md` whose `name` matches the directory name.
