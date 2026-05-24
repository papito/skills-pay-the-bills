SHELL := /bin/sh

SKILLS_SRC ?= skills

COPILOT_SKILLS_DIR ?= $(HOME)/.copilot/skills
COPILOT_NAMESPACE ?= skills-pay-the-bills
COPILOT_TARGET_DIR ?= $(COPILOT_SKILLS_DIR)/$(COPILOT_NAMESPACE)

CLAUDE_SKILLS_DIR ?= $(HOME)/.claude/skills
CLAUDE_ALT_SKILLS_DIR ?= $(HOME)/.config/claude/skills
CLAUDE_NAMESPACE ?= skills-pay-the-bills

CODEX_HOME ?= $(HOME)/.codex
CODEX_SKILLS_DIR ?= $(CODEX_HOME)/skills
CODEX_NAMESPACE ?= skills-pay-the-bills
CODEX_TARGET_DIR ?= $(CODEX_SKILLS_DIR)/$(CODEX_NAMESPACE)

#-a                 archive: preserve permissions, timestamps, symlinks, recurse
#--delete           remove files in DEST that no longer exist in source
#--include='*.md'   copy .md files
#--include='*/'     descend into subdirectories
#--exclude='*'      skip everything else
RSYNC_MD_FILTER := -a --delete --include='*.md' --include='*/' --exclude='*'


.PHONY: deploy-copilot deploy-claude deploy-codex deploy-all

deploy-copilot:
	@mkdir -p "$(COPILOT_TARGET_DIR)"
	@rsync $(RSYNC_MD_FILTER) "$(SKILLS_SRC)/" "$(COPILOT_TARGET_DIR)/" || exit 1
	@echo "Deployed to $(COPILOT_TARGET_DIR)"

deploy-claude:
	@mkdir -p "$(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@rsync $(RSYNC_MD_FILTER) "$(SKILLS_SRC)/" "$(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)/" || exit 1
	@echo "Deployed to $(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@mkdir -p "$(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@rsync $(RSYNC_MD_FILTER) "$(SKILLS_SRC)/" "$(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)/" || exit 1
	@echo "Deployed to $(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"

deploy-codex:
	@mkdir -p "$(CODEX_TARGET_DIR)"
	@rsync $(RSYNC_MD_FILTER) "$(SKILLS_SRC)/" "$(CODEX_TARGET_DIR)/" || exit 1
	@echo "Deployed to $(CODEX_TARGET_DIR)"

deploy-all: deploy-copilot deploy-claude deploy-codex
