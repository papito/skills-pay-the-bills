# skills-pay-the-bills deployment

This repo treats `plan/` as the source of truth for skills content.

The Makefile supports:
- org-level GitHub Copilot deployment via direct push
- local Claude Code sync to `./.claude/skills`

## Prerequisites

- `git`
- `rsync`
- a checked-out org Copilot repo on your machine

## Configuration

Defaults are defined in `Makefile`, and can be overridden per command:

- `SKILLS_SRC` (default: `plan`)
- `COPILOT_REPO_DIR` (default: `../copilot-skills-org`)
- `COPILOT_TARGET_SUBDIR` (default: `skills/skills-pay-the-bills`)
- `CLAUDE_DIR` (default: `./.claude`)
- `CLAUDE_TARGET_SUBDIR` (default: `skills`)
- `DEFAULT_BRANCH` (default: `main`)

## Common commands

```bash
make test
make deploy-claude
make deploy-copilot
make deploy-all
```

## Example with explicit org repo path

```bash
make deploy-copilot COPILOT_REPO_DIR="$HOME/work/org-copilot-skills" DEFAULT_BRANCH="main"
```

## What each deploy does

- `deploy-claude`: syncs `plan/` into `./.claude/skills/`.
- `deploy-copilot`: syncs `plan/` into the configured subfolder in your org Copilot repo, then commits and pushes directly if there are changes.

## Dry-run options

```bash
make dry-run-claude
make dry-run-copilot COPILOT_REPO_DIR="$HOME/work/org-copilot-skills"
```

