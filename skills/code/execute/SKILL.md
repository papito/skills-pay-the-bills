---
name: execute
description: Execute an already-created plan, with multiple interactivity modes
---

<what-to-do>

## General
Implement the plan using its task list.

For each step, spawn a subagent of the same model (and effort, if possible).
After each step, optionally conduct a code review of the work done.
After all steps are done, optionally conduct a holistic code review.

This skill has three modes, which determine the level of user interaction.

1. One-shot: the changes are done without any user interaction (unless ambiguities must be resolved).
2. Cautious: the user reviews the changes for each completed task before the next step 
3. Flow: the user works with the agent on each change


## Code reviews
The code review step should attempt to invoke the review:code-review skill, using a new subagent.

* If review:code-review does not exist, attempt to locate another code review skill the user already has available.
* If none are found, skip this step and warn the user.
* Direct the code review skill to NOT write any output to a file.
* The review subagent then should present the output table to the user (the rest depends on the Mode).
* Resolve all findings selected under the current mode before starting the next task.
* Do not review steps only dedicated to documentation.

What happens after a code review is done depends on the mode:

* ONE-SHOT: Fix all issues.
* CAUTIOUS or FLOW: Ask the user which findings should be fixed, then address them.

In FLOW mode, the usual Flow Mode during code review fixes does not apply - simply go forward with the fixes.


## Flow mode

Flow mode is subject to other user preferences (whether to conduct code reviews and when to commit work), 
but the main difference is in how the code is being written. 

For each edit:

1. Make the edit
2. Explain what it does - this is not just a copy of code comments; it should describe the purpose of this change in the context of the task at hand. What does it do? Why do we need it? Etc.
3. Show the diff on screen and the file location.
4. Ask the user to choose one: 
   - Proceed
   - Ask a question about the code
   - Have the agent make a change
   - Hand-off (let the user manually tweak the code)
5. If the user asks for a change, make it and return to step #2, until the user is ready to move on.
6. If the user chooses Hand-off, pause edits until the user explicitly returns control, then reread their changes before continuing.

It's important to not overwhelm the user with redundant changes. For mechanical, repetitive changes across one or multiple files, bundle those into one prompt.
For example, a variable/method rename should not invoke the Flow for each change. It should be all or nothing.

## The steps

Bullet points describe the steps. Whether code reviews and commits happen is up to user preferences set earlier in the session.

A task is complete when its acceptance criteria and relevant checks pass and selected review findings are resolved.

* A subagent works on one sequential task from a plan. If questions or ambiguities arise during implementation, ask the user to resolve them.
* A new subagent reviews the changes made.
* In Cautious mode, present the completed task, including any review fixes, and wait for user approval before committing or starting the next task.
* Commit
* When all tasks are done, conduct a holistic code review of the entire work
* Commit

Move the plan to `.plans/done` after all tasks, required reviews, fixes, and user approvals are complete.

## What the user must answer

1. What mode would they like to work in?
2. When to commit (choose one)
    - Never
    - After each task, and its review if any
    - After all tasks are done and the final review, if any
3. When to conduct code reviews (checkboxes):
    - After each task
    - Review entire work

</what-to-do>
