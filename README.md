# skills-pay-the-bills

Repository of agent skills, organized by domain:

- `code/`
- `maintain/`
- `plan/`
- `review/`
- `write/`

## Skills Table of Contents

### code

- [`execute-with-flow`](skills/code/execute-with-flow/SKILL.md) - Implement an existing plan in hotshot, cautious, or flow mode. [Setup](skills/code/execute-with-flow/SKILL.md#execution-preferences), [menus and fallbacks](skills/code/execute-with-flow/SKILL.md#user-questions), [Flow workflow](skills/code/execute-with-flow/SKILL.md#flow-mode).

### maintain

- [`update-agent-instructions`](skills/maintain/update-agent-instructions/SKILL.md) - Update root agent-instruction files (such as `AGENTS.md`/`CLAUDE.md`) with minimal, codebase-aligned changes.

### plan

- [`grill-me`](skills/plan/grill-me/SKILL.md) - Challenge a plan against project domain language, update glossary documentation, and save a refined implementation plan in `plans/`.

### review

- [`self-review`](skills/review/self-review/SKILL.md) - Review branch changes for quality, correctness, performance, security, and code smells; save numbered findings in `PR-SELF-REVIEW.md` and ask which issues to fix.
- [`quiz-me-on-your-code`](skills/review/quiz-me-on-your-code/SKILL.md) - Quiz the user on recently written/modified code to verify understanding.

### write

- [`editor`](skills/write/editor/SKILL.md) - Critique writing with a rating, specific weaknesses, strengths, and concrete revision suggestions.
- [`grammar`](skills/write/grammar/SKILL.md) - Find grammar issues, typos, and closely repeated words; list numbered findings with suggested fixes and ask which to apply.

### Prerequisites
- `make`
- `rsync`
- `python3`

### Configuration

Defaults are defined in `Makefile` and can be overridden per command:
- `SKILLS_SRC` (default: `skills`)
- `ALIASES_FILE` (default: `$HOME/.bash_aliases`)
- `COPILOT_SKILLS_DIR` (default: `$HOME/.copilot/skills`)
- `COPILOT_NAMESPACE` (default: `skills-pay-the-bills`)
- `COPILOT_TARGET_DIR` (default: `$COPILOT_SKILLS_DIR/$COPILOT_NAMESPACE`)
- `CLAUDE_SKILLS_DIR` (default: `$HOME/.claude/skills`)
- `CLAUDE_ALT_SKILLS_DIR` (default: `$HOME/.config/claude/skills`)
- `CLAUDE_NAMESPACE` (default: `skills-pay-the-bills`; names the manifest files)
- `CLAUDE_MANIFEST` (default: `$CLAUDE_SKILLS_DIR/.$CLAUDE_NAMESPACE-manifest`)
- `CLAUDE_ALT_MANIFEST` (default: `$CLAUDE_ALT_SKILLS_DIR/.$CLAUDE_NAMESPACE-manifest`)
- `CODEX_HOME` (default: `$HOME/.codex`)
- `CODEX_SKILLS_DIR` (default: `$CODEX_HOME/skills`)
- `CODEX_NAMESPACE` (default: `skills-pay-the-bills`)
- `CODEX_TARGET_DIR` (default: `$CODEX_SKILLS_DIR`)
- `CODEX_MANIFEST` (default: `$CODEX_TARGET_DIR/.$CODEX_NAMESPACE-manifest`)

### Commands

```bash
make deploy-copilot
make deploy-claude
make deploy-codex
make deploy-all
```

After deploying, open a new Bash shell or reload the alias file, then run:

```bash
source ~/.bash_aliases
skills
```

If you override `ALIASES_FILE`, source that file instead.

### Examples

Deploy `review/` skills only:

```bash
make deploy-all SKILLS_SRC="skills/review"
```

Deploy `maintain/` skills only:

```bash
make deploy-all SKILLS_SRC="skills/maintain"
```
