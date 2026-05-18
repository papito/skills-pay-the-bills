SHELL := /bin/sh

SKILLS_SRC ?= plan

COPILOT_SKILLS_DIR ?= $(HOME)/.copilot/skills
COPILOT_NAMESPACE ?= skills-pay-the-bills
COPILOT_TARGET_DIR ?= $(COPILOT_SKILLS_DIR)/$(COPILOT_NAMESPACE)

CLAUDE_SKILLS_DIR ?= $(HOME)/.claude/skills
CLAUDE_ALT_SKILLS_DIR ?= $(HOME)/.config/claude/skills
CLAUDE_NAMESPACE ?= skills-pay-the-bills


.PHONY: deploy-copilot deploy-claude deploy-all

deploy-copilot:
	@mkdir -p "$(COPILOT_TARGET_DIR)"
	@rsync -a --include='*.md' --include='*/' --exclude='*' "$(SKILLS_SRC)/" "$(COPILOT_TARGET_DIR)/" || exit 1
	@echo "Deployed to $(COPILOT_TARGET_DIR)"

deploy-claude:
	@mkdir -p "$(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@rsync -a --include='*.md' --include='*/' --exclude='*' "$(SKILLS_SRC)/" "$(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)/" || exit 1
	@echo "Deployed to $(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@mkdir -p "$(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@rsync -a --include='*.md' --include='*/' --exclude='*' "$(SKILLS_SRC)/" "$(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)/" || exit 1
	@echo "Deployed to $(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"

deploy-all: deploy-copilot deploy-claude
