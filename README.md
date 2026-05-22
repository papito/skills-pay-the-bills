# skills-pay-the-bills

Repository of agent skills, organized by domain:
- `maintain/`
- `plan/`
- `review/`

## Skills Table of Contents

### maintain
- [`update-agent-instructions`](maintain/update-agent-instructions/SKILL.md) - Update root agent-instruction files (such as `AGENTS.md`/`CLAUDE.md`) with minimal, codebase-aligned changes.

### plan
- [`grill-me`](plan/grill-me/SKILL.md) - Stress-test a plan against project language/domain decisions and produce a refined implementation plan.

### review
- [`check-my-pr`](review/check-my-pr/SKILL.md) - Review current branch changes in context and report issues by severity.
- [`quiz-me-on-your-code`](review/quiz-me-on-your-code/SKILL.md) - Quiz the user on recently written/modified code to verify understanding.

## Deployment

The `Makefile` syncs markdown skills (`*.md`) from `SKILLS_SRC` into local Copilot and Claude skill folders.

### Prerequisites
- `make`
- `rsync`

### Configuration

Defaults are defined in `Makefile` and can be overridden per command:
- `SKILLS_SRC` (default: `plan`)
- `COPILOT_SKILLS_DIR` (default: `$HOME/.copilot/skills`)
- `COPILOT_NAMESPACE` (default: `skills-pay-the-bills`)
- `COPILOT_TARGET_DIR` (default: `$COPILOT_SKILLS_DIR/$COPILOT_NAMESPACE`)
- `CLAUDE_SKILLS_DIR` (default: `$HOME/.claude/skills`)
- `CLAUDE_ALT_SKILLS_DIR` (default: `$HOME/.config/claude/skills`)
- `CLAUDE_NAMESPACE` (default: `skills-pay-the-bills`)

### Commands

```bash
make deploy-copilot
make deploy-claude
make deploy-all
```

### Examples

Deploy `review/` skills only:

```bash
make deploy-all SKILLS_SRC="review"
```

Deploy `maintain/` skills only:

```bash
make deploy-all SKILLS_SRC="maintain"
```

