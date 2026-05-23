---
name: grill-me
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
---

<what-to-do>

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

The outcome of this exercise is a new plan – NOT code. The plan should be saved in the `plans/` directory (choose a name that makes sense for the task).
Create the directory if it does not exist.

After all questions are answered, determine the smallest possible set of changes that can be made to the codebase to bring the plan into alignment with the domain model and the project's language.
The changes need to be grouped into logical units that can be easily reviewed and merged. For each unit of work, provide a concise description of the change and its rationale. Use a numbered list to list the changes
so that they can be easily referenced in the future.

The resulting plan should start with the original goals of the larger task.

</what-to-do>

