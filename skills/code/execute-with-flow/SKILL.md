---
name: execute-with-flow
description: Execute an already-created plan, with multiple interactivity modes
---

<what-to-do>

## General
Implement the plan the user provided or referenced, using its task list. If it is unclear which plan to use, or the plan has no task list, ask the user before starting.

Terms used below:
- **Task**: one item from the plan's task list.
- **Edit**: one unit of change presented to the user in Flow mode.

This skill has three modes, which determine the level of user interaction.

1. Hotshot: after setup, tasks are done without user interaction, unless ambiguities must be resolved or checks keep failing.
2. Cautious: the user approves each completed task before the next task starts.
3. Flow: the user works with the agent on each implementation edit and selects review findings to fix.

The parent agent coordinates user interaction, task sequencing, and commits.
- In Hotshot and Cautious modes, spawn one implementation subagent per task, using the same model (and effort, if possible). Subagents cannot talk to the user: if questions or ambiguities arise, the subagent stops and returns them to the parent, which asks the user and resumes the subagent with the answers.
- In Flow mode, the parent implements each task directly.

After each task, optionally conduct a code review of the work done.
After all tasks are done, optionally conduct a holistic code review.

## Before starting

1. Identify the project's version control system (VCS), if any, and the available tools for it. A repository with no commits still counts as a VCS project.
2. Resolve execution preferences as described under "Execution preferences".
3. If a VCS is present, the working copy has pre-existing changes, and the effective commit policy is not `never`, ask the user how to handle them. Offer only strategies supported by the available tools:
    - Temporarily set them aside until the plan is done
    - Commit them first
    - Leave them in place, and commit only changes made while executing the plan
4. Take the starting snapshot (see "Snapshots").

## Execution preferences

Leave ignore configuration for `flow.yaml` to the user.

1. Locate `flow.yaml` in the main project directory the user is currently working on: use the VCS working-copy root when appropriate, otherwise the project's root directory. Load this project file, not the example in the skill folder.
2. Read the fields below. If the file is absent, treat all fields as missing. Explicit user preferences from the current conversation override saved values. Treat missing, null, or unsupported values as unresolved; `false` is a valid review preference.
3. If `flow.yaml` supplied any valid values applicable to this run and not overridden by the conversation, show the user those saved settings (plus any applicable conversation overrides) and ask whether they are acceptable for this run. Wait for the answer. Skip this step when the file supplied no applicable valid values.
    - Accepted: keep the confirmed saved values as resolved.
    - Not accepted: discard saved values for applicable fields and treat those fields as unresolved, except values the user stated explicitly in this conversation.
4. Ask only for unresolved preferences applicable to this run using "Preference questions", and wait for answers. Do not use the example's values or rejected saved values as defaults. Do not ask for confirmation again after collecting answers.
5. Save all resolved preferences to the same project-root `flow.yaml` before implementation starts, creating it if needed. Preserve saved values for inapplicable fields unless the user explicitly changes them, along with unrelated YAML keys and existing comments where possible. If the existing YAML cannot be parsed, resolve that problem before updating it.
6. If the user changes preferences later, update this file and use the new values for subsequent work.

| YAML field | Allowed values |
| --- | --- |
| `execution.mode` | `hotshot`, `cautious`, `flow` |
| `execution.commit` | `never`, `after_each_task`, `after_all_tasks` |
| `execution.reviews.after_each_task` | `true`, `false` |
| `execution.reviews.entire_plan` | `true`, `false` |
| `execution.reviews.skill` | Name of a code review skill available in this session |

`execution.commit` applies only when a VCS is present; its resolved value is the effective commit policy. Without a VCS, explain that commits are unavailable and use `never` as the effective policy for this run. Skip resolving or confirming `execution.commit`; preserve its saved value (or absence) unless the user explicitly changes it. Continue implementation, snapshots, and reviews without initializing a repository. References below to commit policy mean the effective policy for the run.

The review flags are independent; setting both to `false` disables code reviews. `execution.reviews.skill` is needed only when at least one review flag is `true` and a code review skill is available; leave a saved value in place when reviews are disabled.

During preference resolution, if reviews are enabled but no code review skill is available, warn the user and skip reviews for this run. Do not ask for or require resolution of `execution.reviews.skill`. Preserve the resolved review flags and any saved skill value in `flow.yaml`; leave the skill field absent if it was absent.

## Snapshots

Snapshots record project file state independently of commits and must work without a repository or an existing revision. Take one at the start of the plan, after implementing each task, and again whenever changes are modified afterwards (review fixes, user-requested changes). The latest snapshot replaces the earlier one taken at the same point.

Use suitable VCS snapshot facilities when available, otherwise keep temporary filesystem copies outside the project. Capture current file contents, including pre-existing edits and untracked files relevant to the plan. Preserve paths, binary contents, and relevant metadata so additions, modifications, and deletions can be compared. Exclude VCS metadata and unrelated generated files. Creating snapshots must preserve working files, existing staging state, and repository history.

- A task's changes: compare the snapshot before the task with the snapshot after it. The snapshot before a task is the previous task's latest snapshot, or the starting snapshot for the first task.
- All changes made while executing the plan: compare the starting snapshot with the latest snapshot.

Retain the snapshots needed for task reviews, the whole-plan review, and pending commits until execution is complete. Use their diffs for review scopes and to identify intended commit contents; committing that exact change set is a separate VCS operation.

## Committing

Use the project's VCS and the effective commit policy. Plan commits must contain only changes made while executing the plan; pre-existing changes may be committed separately if the user chose that setup option.

1. Identify pending plan changes by comparing the latest snapshot with the snapshot at the last successful plan commit, or the starting snapshot if there was none. Skip the commit if that diff is empty.
2. Use the available VCS tools to prepare exactly those changes, preserving unrelated working-copy changes and any existing staging state.
3. Verify the proposed commit contents before committing. If the tools cannot reliably isolate or verify the intended changes, ask the user how to proceed.
4. After successfully committing the full intended change set, record its snapshot as the baseline for the next commit. Keep the starting snapshot for the whole-plan review.

The commit message is one short sentence conveying the overall theme of the changes.

## Code reviews
The code review step invokes the skill named in `execution.reviews.skill`, using a new subagent. Give the subagent that exact skill name.

* If no code review skill is available, skip this step and warn the user if not already warned during setup.
* Otherwise, if the selected skill is not available, tell the user, ask them to choose another available code review skill (see "Preference questions"), and save the choice to `flow.yaml`.
* Pass the reviewer the task's diff (per-task review) or the whole plan's diff (holistic review), as described under "Snapshots".
* In the delegation prompt, instruct the review subagent to only return numbered findings in a table to the parent agent, without asking the user questions or implementing fixes.
* The parent agent presents findings to the user and handles selection according to the current mode.
* Resolve all findings selected under the current mode before starting the next task.
* Do not review tasks only dedicated to documentation.

What happens after a code review is done depends on the mode:

* HOTSHOT: Fix all issues.
* CAUTIOUS or FLOW: Ask the user which findings should be fixed, then address them.

Who applies the fixes:
* Per-task review in Hotshot or Cautious: the task's implementation subagent (resume it if possible; otherwise spawn a new one with the findings and the task's diff).
* Holistic review in Hotshot or Cautious: a new subagent.
* Flow mode: the parent, as described under "Flow mode" > "Review fixes".

## Flow mode

Flow mode is subject to other user preferences (whether to conduct code reviews and when to commit work),
but the main difference is in how the code is being written: the user sees, understands, and approves every edit except selected review fixes (see "Review fixes").

### Sizing edits
- An edit is one coherent change the user can review at a glance: usually one concern, in one file or a few closely related places. A task normally takes several edits; never present a whole multi-file task as one edit.
- Bundle mechanical, repetitive changes (renames, import updates, moved code) into one edit, even across files. A rename is all or nothing; do not run the loop for each occurrence.

### Making edits
- Use the file-editing tools (such as Edit and Write), not shell commands, scripts, or `sed`, so the user's interface shows the change. A script is acceptable only for a bundled mechanical edit.
- Keep edits separate from running commands: never combine an edit with a build or test run in one command. If a quick check confirms the edit (for example, a new test that should fail), run it as a separate command after the edit and report the result at the checkpoint. Run the task's checks after its last edit is approved.

### The checkpoint
Tool output, including diffs printed by shell commands, may be hidden or collapsed for the user; it does not count as showing them anything. Before asking about an edit, write a visible message in your reply text with:
1. A heading: `Task N · Edit M — <short title>`.
2. Locations: each changed file as `path:line`.
3. What and why: the purpose of the change in the context of the task. What does it do? Why is it needed? Which non-obvious choices did you make? Do not restate the code comments.
4. The diff, in a fenced `diff` block in the message text. For a bundled mechanical edit, give a summary and a representative excerpt instead, plus the command to see the full diff.
5. The result of any check run on the edit.

Never ask about an edit unless this message directly precedes the question. This applies to every edit, including the last edit of a task and edits late in a long session.

### The loop
For each edit:

1. Make the edit.
2. Write the checkpoint message.
3. Ask the user to choose one:
    - Proceed
    - Ask a question about the code
    - Have the agent make a change
    - Hand-off (let the user manually tweak the code)

    If the question tool supports per-option previews (such as `preview` in Claude Code's AskUserQuestion), also put the edit's diff in the Proceed option's preview, trimmed to the most relevant hunks if it is long, so the diff stays visible while the user decides. The preview supplements the checkpoint message; it never replaces it.
4. If the user asks a question, answer it and return to step 2, repeating the checkpoint before asking again.
5. If the user asks for a change, make it and return to step 2, showing the updated diff.
6. If the user chooses Hand-off, pause edits until the user explicitly returns control, then reread their changes and briefly summarize them before continuing.

### Review fixes
Selecting review findings authorizes the parent to apply their fixes directly, without the per-edit loop or individual edit approvals. Afterwards, write one visible summary covering each fixed finding: its number, `path:line` locations, what changed and why, and the diff in a fenced `diff` block.

## The steps

Whether code reviews and commits happen follows the resolved execution preferences and availability rules above.

A task is complete when its acceptance criteria and relevant checks pass and selected review findings are resolved. If checks still fail after a reasonable attempt to fix them, stop and ask the user how to proceed, in every mode.

For each task, in plan order:
1. Implement the task (subagent in Hotshot and Cautious, parent in Flow).
2. Run relevant checks (in Flow, after the task's last edit is approved).
3. Take a snapshot.
4. If per-task reviews are enabled, review the task's changes with a new subagent, resolve selected findings, rerun affected checks, and retake the snapshot.
5. In Cautious mode, present the completed task, including any review fixes, and wait for user approval. If the user requests changes, apply them, rerun affected checks, retake the snapshot, and present the task again.
6. If the commit policy is `after_each_task`, commit the task as described under "Committing".

After all tasks:
1. If the holistic review is enabled, review all changes made while executing the plan with a new subagent.
    - Resolve selected findings, rerun affected checks, and retake the snapshot.
    - In Cautious mode, obtain user approval of the final fixes before committing.
2. If the commit policy is `after_all_tasks`, commit the completed work. If it is `after_each_task`, commit any final review fixes. Never commit when the policy is `never`.
3. If pre-existing changes were temporarily set aside, restore them using the corresponding mechanism and tell the user about any conflicts.

## Preference questions

Ask only for applicable values still unresolved after loading `flow.yaml`, applying explicit preferences from the conversation, and confirming applicable saved settings with the user.

1. Which mode to work in (choose one):
    - Hotshot: no interaction after setup
    - Cautious: approve each completed task
    - Flow: work through each edit together
2. When to commit (choose one; ask only when a VCS is present):
    - Never
    - After each task, and its review if any
    - After all tasks are done and the final review, if any
3. When to conduct code reviews (checkboxes):
    - After each task
    - After all tasks (entire plan)
4. Which code review skill to use (choose one; ask only if at least one review is enabled and a code review skill is available):
    - List the code review skills available in this session, with `self-review` first when it is available.

</what-to-do>
