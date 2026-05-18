---
name: update-agent-instructions
description: Update the existing agents file in the project root for guiding AI coding agents.
tools: ['insert_edit_into_file', 'read_file']
---

<what-to-do>

Update the existing AGENTS.md or CLAUDE.md, whichever file is present, for guiding AI coding agents.
There may be other, nested agents files present in subfolders.
Read the existing agents file in full BEFORE doing anything else. Understand its structure, sections, and content thoroughly. This is your baseline — everything here is assumed correct unless proven otherwise.
Analyze the codebase to identify ONLY what has changed or is missing compared to the existing agents file. Focus on the essential aspects that would help AI agents be immediately productive in this codebase, e.g.,:
Architecture changes: new/removed components, altered service boundaries or data flows
Workflow changes: new build commands, changed test procedures, updated debugging steps
Convention changes: new patterns, deprecated practices, renamed files/directories
New integration points or external dependencies
Source existing AI conventions from **/{.github/copilot-instructions.md,AGENT.md,AGENTS.md,CLAUDE.md,.cursorrules,.windsurfrules,.clinerules,.cursor/rules/**,.windsurf/rules/**,.clinerules/**,README.md} (do one glob search).
Apply minimal, surgical updates. Follow these guidelines (read more at https://agents.md/):
Do NOT rewrite or rephrase sections that are still accurate — leave them exactly as they are
Preserve the existing structure, section ordering, and formatting
When adding content, place it in the most logical existing section rather than creating new sections
Write concise, actionable instructions using markdown structure
Include specific examples from the codebase when describing patterns
Avoid generic advice ("write tests", "handle errors") - focus on THIS project's specific approaches
Document only discoverable patterns, not aspirational practices
Reference key files/directories that exemplify important patterns

</what-to-do>