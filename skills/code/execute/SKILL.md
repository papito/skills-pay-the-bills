---
name: execute
description: Execute an already-created plan
---

<what-to-do>

Implement this plan using the task list.

If questions or ambiguities arise during implementation, please ask them.

IMPORTANT: If the prompt mentions the word "interactive", please ask the user first before proceeding in the following instances:

* Do they want to continue after a single plan point has been completed, but before the code review commences. The user needs a chance to review the changes manually.
* The list of issue numbers to fix after each code review. You can then proceed to implementing the next step once all the fixes are in.

For each step, spawn a subagent of the same model (and effort, if possible).

When a subagent is done, conduct a code review using the review:code-review skill, using another subagent (skip this step for documentation tasks!).
Direct the subagent to only look at the uncommited changes related to the current task number.

Use the same model (and effort if possible), and direct the review subagent to NOT write the output to a file.
The subagent should present the output table to the user and proceed to fix any issues before moving on to the next implementation step. 
Only stop and confirm in interactive mode

When a step implementation is done, do commit each step with a short, one-sentence commit message - this may override the global directive to not commit.

When all the steps are complete - invoke the review:code-review skill, but this time directly, on the entire branch.

After implementation of all tasks is complete, move the to the .plans/done folder.

Note to user that the final code review was written to file for review.

</what-to-do>
