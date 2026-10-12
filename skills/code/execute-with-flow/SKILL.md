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
3. Flow: the user works with the agent on each implementation edit and selects review findings to fix. The user can switch to Cautious or Hotshot from the edit menu at any point and continue the run.

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
    - The review skill question depends on the review flags: resolve both flags first, then ask it in a separate round only if at least one flag is `true`. Never include it in the same batch as the review checkboxes.
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

The review flags are independent; setting both to `false` disables code reviews. `execution.reviews.skill` is applicable only when at least one review flag is `true` and a code review skill is available. When both flags are `false` (saved, confirmed, or newly chosen), the skill field is inapplicable: do not ask for it, confirm it, or require it, even if it is missing from `flow.yaml`; leave any saved value in place.

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
- An edit is one coherent behavior or change the user can review at a glance. A small implementation change and its focused test may form one edit across files, even if that completes the task. Split unrelated concerns into separate edits.
- Bundle mechanical, repetitive changes (renames, import updates, moved code) into one edit, even across files. A rename is all or nothing; do not run the loop for each occurrence.

### The pending edit
- Keep one unapproved implementation edit at a time. Before modifying a file, preserve its current contents and relevant metadata, or record its absence for a new file, as the edit's baseline. This baseline is separate from task and plan snapshots; extend it before a revision first touches another file.
- Keep the same edit number and baseline through questions, revisions, and hand-offs. Show the complete pending diff against that baseline, including user changes within the edit. Advance the baseline and edit number only after acceptance.
- Retain enough change history to distinguish pending agent changes from pre-existing changes, accepted edits, and user changes when discarding an edit.

### Making edits
- Use the file-editing tools (such as Edit and Write), not shell commands, scripts, or `sed`, so the user's interface shows the change. A script is acceptable only for a bundled mechanical edit.
- Keep edits separate from running commands: never combine an edit with a build or test run in one command. If a quick check confirms the edit (for example, a new test that should fail), run it as a separate command after the edit and report the result at the checkpoint. Run the task's checks after its last edit is approved.
- Corrections required by task checks go through the edit loop as new edits; rerun affected checks after acceptance. Fixes covered by selected review findings follow "Review fixes" instead.

### The checkpoint
Tool output, including diffs printed by shell commands, may be hidden or collapsed for the user; it does not count as showing them anything. Neither does text placed in a question tool's option labels, descriptions, or previews. Before asking about an edit, write a visible message in your reply text with:
1. A heading: `Task N · Edit M — <short title>`.
2. Locations: each changed file as `path:line`.
3. What and why: usually a few sentences explaining the changed behavior, its purpose, and any meaningful tradeoff. Avoid repeating unchanged task context or code comments.
4. The complete pending diff against the edit's baseline, in a fenced `diff` block in the message text. For a bundled mechanical edit, give a summary and a representative excerpt instead, plus the command to see the full diff.
5. Check status: passed, failed as expected (explain why), failed unexpectedly, or not run. Report the results of checks that ran.

Never ask about an edit unless this message directly precedes the question. This applies to every edit, including the last edit of a task and edits late in a long session.

### The loop
For each edit:

1. Capture the edit's baseline and make the edit.
2. Write the checkpoint message.
3. Ask the user to choose one:
    - Accept edit and continue
    - Ask a question about the code
    - Have the agent make a change
    - Discard this edit
    - Hand-off (let the user manually tweak the code)
    - Switch to Cautious or Hotshot mode and continue

    The checkpoint message is the only place the diff is shown. Never put code, diff lines, or file contents into the question tool's option labels, descriptions, or previews; keep the options to the short labels above. If the harness has no structured question tool, end the checkpoint message with the numbered option list and wait for the user's reply.
4. On acceptance, mark the pending edit approved, advance the baseline to the accepted state, and increment the edit number. Start the next edit, or run task checks if implementation is complete.
5. If the user asks a question, answer it and return to step 2, repeating the checkpoint with a concise explanation before asking again.
6. If the user asks for a change, revise the pending edit and return to step 2, showing its complete updated diff against the original baseline.
7. If the user chooses Discard, reread affected files and remove only pending agent changes, preserving pre-existing changes, accepted edits, and user changes. If changes overlap or ownership is unclear, show a checkpoint and ask how to reconcile them before reverting anything. Summarize the result; if user changes remain pending, return to step 2 for acceptance. Otherwise, ask how to continue and reuse the edit number for a replacement.
8. If the user chooses Hand-off, pause agent edits and commands that modify the project until the user explicitly returns control. Reread their changes, briefly summarize their effect, and return to step 2 for acceptance. Returning control does not approve the edit.
9. If the user chooses Switch, ask which mode to continue in (Cautious or Hotshot) unless they already named it, then follow "Switching mode mid-run".

### Switching mode mid-run
Choosing Switch from the edit menu accepts the pending edit: mark it approved and advance the baseline as in step 4 of the loop. Then:

1. Update `execution.mode` in `flow.yaml` to the chosen mode (see "Execution preferences"). Other preferences are unchanged.
2. Finish the current task directly as the parent, without further checkpoints or edit approvals, then run its checks and take the snapshot.
3. From that task's review step onward, apply the new mode's rules: in Cautious, ask which findings to fix and present the completed task for approval; in Hotshot, fix all findings and continue without asking. Review fixes for this task are applied by the parent.
4. From the next task on, spawn implementation subagents as the new mode requires. The edit loop does not run again unless the user explicitly asks to return to Flow mode.

### Review fixes
Selecting review findings authorizes the parent to apply their fixes directly, without the per-edit loop or individual edit approvals. Afterwards, write one visible summary covering each fixed finding: its number, `path:line` locations, what changed and why, and the diff in a fenced `diff` block.

## The steps

Whether code reviews and commits happen follows the resolved execution preferences and availability rules above.

A task is complete when its acceptance criteria and relevant checks pass and selected review findings are resolved. If checks still fail after a reasonable attempt to fix them, stop and ask the user how to proceed, in every mode.

For each task, in plan order:
1. Implement the task (subagent in Hotshot and Cautious, parent in Flow or when the mode was switched during the task).
2. Run relevant checks (in Flow, after the task's last edit is approved).
3. Take a snapshot.
4. If per-task reviews are enabled, review the task's changes with a new subagent, resolve selected findings, rerun affected checks, and retake the snapshot.
5. In Cautious mode, present the completed task, including any review fixes, and wait for user approval. If the user requests changes, apply them, rerun affected checks, retake the snapshot, and present the task again.
6. In Flow mode, summarize how the acceptance criteria were met and report the final check results, without adding a separate task approval.
7. If the commit policy is `after_each_task`, commit the task as described under "Committing".

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
4. Which code review skill to use (choose one; ask only after the review flags are resolved, and only if at least one review is enabled and a code review skill is available; skip entirely when no review is selected):
    - List the code review skills available in this session, with `self-review` first when it is available.

</what-to-do>
