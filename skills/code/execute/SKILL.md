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
* The review subagent then should present the output table to the user and proceed to fix any issues before moving on to the next implementation step.
* Ask the user which issue numbers to fix after each code review. You can then proceed to implementing the next step once all the fixes are in.
* Do not review steps only dedicated to documentation.

## Flow mode

Flow mode is subject to other user preferences (whether to conduct code reviews and when to commit work), 
but the main difference is in how the code is being written. 

For each change:

1. Make the change
2. Explain what it does - this is not just a copy of code comments; it should describe the purpose of this change in the context of the task at hand. What does it do? Why do we need it? Etc.
3. Show the diff on screen.
4. Ask the user to choose one: 
   - Proceed
     - Ask a question about the code
     - Have the agent make a change
     - Hand-off (let the user manually tweak the code)
5. If the user asks for a change, make it and go to step #1 again, until the user is ready to move on.

## The steps

Bullet points describe mandatory steps. Sub-bullets describe what should happen based on the Mode.

* A subagent works on one task from a plan. If questions or ambiguities arise during implementation, ask the user to resolve them.
* A new subagent reviews the changes made.
  - ONE-SHOT: optionally commit and move on to the next task.
  - CAUTIOUS: give the user a chance to look at the changes before moving on. When the user agrees with the changes, optionally commit and move on to the next task.
* When all tasks are done, optionally conduct the holistic code review of the entire work, then optionally commit.

After implementation of all tasks is complete, move the plan to the .plans/done folder.

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
