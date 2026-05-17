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
	@cp -R "$(SKILLS_SRC)/." "$(COPILOT_TARGET_DIR)/"
	@echo "Deployed to $(COPILOT_TARGET_DIR)"

deploy-claude:
	@mkdir -p "$(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@cp -R "$(SKILLS_SRC)/." "$(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)/"
	@echo "Deployed to $(CLAUDE_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@mkdir -p "$(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"
	@cp -R "$(SKILLS_SRC)/." "$(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)/"
	@echo "Deployed to $(CLAUDE_ALT_SKILLS_DIR)/$(CLAUDE_NAMESPACE)"

deploy-all: deploy-copilot deploy-claude
