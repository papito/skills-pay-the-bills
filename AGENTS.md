# This repository contains various agent skills

## Repository layout
- Skills live under `skills/<domain>/<skill>/SKILL.md`.
- Current top-level domains are `maintain/`, `plan/`, and `review/`.

## Working rules for agents
- When a skill is updated, added, or removed, update the `README.md` Skills Table of Contents in the same change.
- Keep skill instructions concise and action-oriented; preserve existing frontmatter keys (`name`, `description`, and `tools` when present).
- Treat `Makefile` as the deployment source of truth (it syncs markdown files from `SKILLS_SRC`, default `skills/`).
- If deployment behavior or defaults change in `Makefile`, update the matching Deployment section in `README.md`.
