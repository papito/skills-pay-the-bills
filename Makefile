SHELL := /bin/sh

SKILLS_SRC ?= skills
ALIASES_FILE ?= $(HOME)/.bash_aliases

COPILOT_SKILLS_DIR ?= $(HOME)/.copilot/skills
COPILOT_NAMESPACE ?= skills-pay-the-bills
COPILOT_TARGET_DIR ?= $(COPILOT_SKILLS_DIR)/$(COPILOT_NAMESPACE)

CLAUDE_SKILLS_DIR ?= $(HOME)/.claude/skills
CLAUDE_ALT_SKILLS_DIR ?= $(HOME)/.config/claude/skills
CLAUDE_NAMESPACE ?= skills-pay-the-bills
CLAUDE_MANIFEST ?= $(CLAUDE_SKILLS_DIR)/.$(CLAUDE_NAMESPACE)-manifest
CLAUDE_ALT_MANIFEST ?= $(CLAUDE_ALT_SKILLS_DIR)/.$(CLAUDE_NAMESPACE)-manifest

CODEX_HOME ?= $(HOME)/.codex
CODEX_SKILLS_DIR ?= $(CODEX_HOME)/skills
CODEX_NAMESPACE ?= skills-pay-the-bills
CODEX_TARGET_DIR ?= $(CODEX_SKILLS_DIR)
CODEX_MANIFEST ?= $(CODEX_TARGET_DIR)/.$(CODEX_NAMESPACE)-manifest

#-a                 archive: preserve permissions, timestamps, symlinks, recurse
#--delete           remove files in DEST that no longer exist in source
#--include='*.md'   copy .md files
#--include='*/'     descend into subdirectories
#--exclude='*'      skip everything else
RSYNC_MD_FILTER := -a --delete --include='*.md' --include='*/' --exclude='*'


.PHONY: update-aliases deploy-copilot deploy-claude deploy-codex deploy-all

deploy-copilot: update-aliases
	@mkdir -p "$(COPILOT_TARGET_DIR)"
	@rsync $(RSYNC_MD_FILTER) "$(SKILLS_SRC)/" "$(COPILOT_TARGET_DIR)/" || exit 1
	@echo "Deployed to $(COPILOT_TARGET_DIR)"

deploy-claude: update-aliases
	@sh scripts/deploy-flat.sh "$(SKILLS_SRC)" "$(CLAUDE_SKILLS_DIR)" "$(CLAUDE_MANIFEST)"
	@sh scripts/deploy-flat.sh "$(SKILLS_SRC)" "$(CLAUDE_ALT_SKILLS_DIR)" "$(CLAUDE_ALT_MANIFEST)"

deploy-codex: update-aliases
	@sh scripts/deploy-flat.sh "$(SKILLS_SRC)" "$(CODEX_TARGET_DIR)" "$(CODEX_MANIFEST)"

deploy-all: deploy-copilot deploy-claude deploy-codex

update-aliases:
	@python3 scripts/update-skills-alias.py "$(SKILLS_SRC)" "$(ALIASES_FILE)"
	@echo "Updated skills function in $(ALIASES_FILE)"
