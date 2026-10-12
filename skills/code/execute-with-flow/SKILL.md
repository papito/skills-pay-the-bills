---
name: execute-with-flow
description: Execute an already-created plan, with multiple interactivity modes
---

<what-to-do>

## General
Implement the plan the user provided or referenced, using its task list. If it is unclear which plan to use, or the plan has no task list, ask before starting.

Terms: a **task** is one item from the plan's task list; an **edit** is one unit of change presented to the user in Flow mode.

The three modes set the level of user interaction:

| | Hotshot | Cautious | Flow |
| --- | --- | --- | --- |
| Interaction | None after setup, except ambiguities or checks that keep failing | Approves each completed task | Works through each edit with the agent |
| Implements a task | One subagent per task | One subagent per task | Parent (see "Flow mode") |
| Review findings | Fix all | User selects which to fix | User selects which to fix |
| Applies review fixes | Task's subagent (per-task), new subagent (holistic) | Same as Hotshot | Parent, directly (see "Review fixes") |
| Task approval | None | Present the completed task, including review fixes, and wait for approval | None; summarize how acceptance criteria were met and report check results |

The parent coordinates user interaction, task sequencing, and commits. Implementation subagents use the same model (and effort, if possible) and cannot talk to the user: when questions or ambiguities arise, the subagent stops and returns them to the parent, which asks the user and resumes it with the answers. "Task's subagent" means resume it if possible, otherwise spawn a new one with the findings and the task's diff. In Flow mode the user can switch to Cautious or Hotshot from the edit menu (see "Switching mode mid-run").

## Before starting

1. Identify the project's version control system (VCS), if any, and its available tools. A repository with no commits still counts.
2. Resolve execution preferences (below).
3. If a VCS is present, the working copy has pre-existing changes, and the effective commit policy is not `never`, ask how to handle them, offering only strategies the tools support: set them aside until the plan is done; commit them first; leave them in place and commit only plan changes.
4. Take the starting snapshot.

## Execution preferences

Preferences live in `flow.yaml` at the root of the project the user is working on (the VCS working-copy root when appropriate). Load that file, not the example in the skill folder; leave its ignore configuration to the user.

| YAML field | Allowed values | Question when unresolved |
| --- | --- | --- |
| `execution.mode` | `hotshot`, `cautious`, `flow` | Which mode (choose one): Hotshot, no interaction after setup; Cautious, approve each completed task; Flow, work through each edit together |
| `execution.commit` | `never`, `after_each_task`, `after_all_tasks` | When to commit (choose one): never; after each task and its review, if any; after all tasks and the final review, if any |
| `execution.reviews.after_each_task` | `true`, `false` | When to review (checkboxes): after each task; after all tasks (entire plan) |
| `execution.reviews.entire_plan` | `true`, `false` | Same checkbox question |
| `execution.reviews.skill` | Name of a code review skill available in this session | Which review skill (choose one): the available code review skills, `self-review` first when available |

Resolution:
1. Read the file; if absent, treat every field as missing. Missing, null, or unsupported values are unresolved; `false` is a valid review value. Explicit preferences from the current conversation override saved values.
2. If the file supplied valid, applicable values not overridden by the conversation, show them (with any conversation overrides) and ask whether they are acceptable for this run; wait for the answer. If not accepted, treat those fields as unresolved, except values the user stated explicitly in this conversation.
3. Ask only for unresolved applicable fields, using the questions in the table, and wait. Never use the example's values or rejected saved values as defaults, and do not ask for confirmation again after collecting answers. Ask the review-skill question in a separate round after both review flags are resolved, never in the same batch as the review checkboxes.
4. Save all resolved preferences to the same `flow.yaml` before implementation starts, creating it if needed. Preserve values of inapplicable fields, unrelated keys, and comments where possible. If the existing YAML cannot be parsed, resolve that first.
5. If the user changes preferences later, update the file and use the new values from then on.

Applicability:
- `execution.commit` applies only when a VCS is present. Without one, explain that commits are unavailable, use `never` as the effective policy, skip resolving or confirming the field, and continue implementation, snapshots, and reviews without initializing a repository. "Commit policy" below means the effective policy.
- The review flags are independent; both `false` disables reviews. `execution.reviews.skill` applies only when at least one review flag is `true` and a code review skill is available. Otherwise do not ask for, confirm, or require it, even if missing; leave any saved value in place.
- If reviews are enabled but no code review skill is available, warn the user and skip reviews for this run, keeping the resolved flags.

## Snapshots

Snapshots record project file state independently of commits and must work without a repository or revision. Take one at the start, after implementing each task, and again whenever changes are modified afterwards (review fixes, user-requested changes); the latest replaces the earlier one at the same point. Use VCS snapshot facilities when available, otherwise temporary copies outside the project. Capture current contents, including pre-existing edits and relevant untracked files, with paths, binary contents, and metadata; exclude VCS metadata and unrelated generated files. Never disturb working files, staging state, or repository history.

- A task's changes: diff the previous task's latest snapshot (or the starting snapshot) against the task's snapshot.
- All plan changes: diff the starting snapshot against the latest snapshot.

Retain snapshots until execution is complete; their diffs define review scopes and intended commit contents.

## Committing

Plan commits contain only changes made while executing the plan; pre-existing changes may be committed separately if the user chose that setup option.

1. Diff the latest snapshot against the snapshot at the last successful plan commit (or the starting snapshot). Skip the commit if empty.
2. Prepare exactly those changes with the VCS tools, preserving unrelated working-copy changes and existing staging state.
3. Verify the proposed contents before committing. If the tools cannot reliably isolate or verify them, ask the user.
4. After committing, record that snapshot as the baseline for the next commit; keep the starting snapshot for the holistic review.

The commit message is one short sentence conveying the overall theme of the changes.

## Code reviews

Each review runs in a new subagent given the exact skill name from `execution.reviews.skill` and the task's diff (per-task) or the whole plan's diff (holistic). Instruct it to return only numbered findings in a table, without asking the user questions or implementing fixes. The parent presents the findings and handles selection and fixes per the mode table. Resolve selected findings before the next task. Skip reviews when no code review skill is available (warn if not already warned) and for tasks dedicated only to documentation. If the selected skill is not available, ask the user to pick another available one and save it to `flow.yaml`.

## Flow mode

Flow mode follows the same review and commit preferences; the difference is that the user sees, understands, and approves every edit except selected review fixes.

### Sizing edits
- An edit is one coherent change the user can review at a glance; a small change and its focused test may form one edit across files, even if that completes the task. Split unrelated concerns.
- Bundle mechanical, repetitive changes (renames, import updates, moved code) into one edit, even across files; do not loop per occurrence.

### The pending edit
- Keep one unapproved edit at a time. Before modifying a file, record its contents and metadata (or its absence) as the edit's baseline, separate from task snapshots; extend the baseline before a revision first touches another file.
- Keep the same edit number and baseline through questions, revisions, and hand-offs; advance both only on acceptance. Always show the complete pending diff against the baseline, including user changes within the edit.
- Retain enough history to distinguish pending agent changes from pre-existing changes, accepted edits, and user changes.

### Making edits
- Use file-editing tools (Edit, Write), not shell commands or scripts, so the user's interface shows the change; a script is acceptable only for a bundled mechanical edit.
- Never combine an edit with a build or test run. A quick confirming check (such as a new test that should fail) runs as a separate command after the edit and is reported at the checkpoint. Run the task's checks after its last edit is approved.
- Corrections required by task checks go through the loop as new edits; rerun affected checks after acceptance. Fixes for selected review findings follow "Review fixes".

### The checkpoint
Tool output, collapsed diffs, and question-tool option labels, descriptions, or previews do not count as showing the user anything. Before every question about an edit, including the last edit of a task and edits late in a long session, write a visible message in your reply text that directly precedes the question, with:
1. Heading: `Task N · Edit M — <short title>`.
2. Locations: each changed file as `path:line`.
3. What and why: a few sentences on the changed behavior, its purpose, and any meaningful tradeoff; do not repeat unchanged context or code comments.
4. The complete pending diff against the baseline in a fenced `diff` block. For a bundled mechanical edit, a summary, a representative excerpt, and the command to see the full diff.
5. Check status: passed, failed as expected (explain why), failed unexpectedly, or not run, with results of checks that ran.

### The loop
1. Capture the baseline and make the edit.
2. Write the checkpoint message.
3. Ask the user to choose one, keeping options to these labels and never placing code in them; without a structured question tool, end the checkpoint with this numbered list and wait:
    - Accept edit and continue
    - Ask a question about the code
    - Have the agent make a change
    - Discard this edit
    - Hand-off (let the user manually tweak the code)
    - Switch to Cautious or Hotshot mode and continue
4. Accept: mark approved, advance the baseline and edit number, then start the next edit or run task checks if implementation is complete.
5. Question: answer, then return to step 2 with a concise explanation.
6. Change: revise the pending edit, then return to step 2 with the complete updated diff against the original baseline.
7. Discard: reread affected files and remove only pending agent changes. If changes overlap or ownership is unclear, show a checkpoint and ask how to reconcile before reverting. Summarize; if user changes remain pending, return to step 2, otherwise ask how to continue and reuse the edit number.
8. Hand-off: pause project-modifying edits and commands until the user explicitly returns control, then reread their changes, summarize their effect, and return to step 2. Returning control does not approve the edit.
9. Switch: ask which mode (Cautious or Hotshot) unless named, then follow "Switching mode mid-run".

### Switching mode mid-run
Switching accepts the pending edit as in step 4. Then update `execution.mode` in `flow.yaml` (other preferences unchanged), finish the current task directly as the parent without further checkpoints, run its checks, and take the snapshot. From that task's review step onward apply the new mode's rules, with the parent applying this task's review fixes. From the next task on, use subagents as the new mode requires. The loop does not resume unless the user explicitly asks to return to Flow.

### Review fixes
Selecting findings authorizes the parent to fix them directly, without the loop. Afterwards write one visible summary covering each fixed finding: its number, `path:line` locations, what changed and why, and the diff in a fenced `diff` block.

## The steps

A task is complete when its acceptance criteria and checks pass and selected review findings are resolved. If checks still fail after a reasonable attempt, stop and ask the user, in every mode.

For each task, in plan order:
1. Implement it (parent in Flow or after a mid-task switch, subagent otherwise).
2. Run relevant checks (in Flow, after the last edit is approved).
3. Take a snapshot.
4. If per-task reviews are enabled, review, resolve selected findings, rerun affected checks, and retake the snapshot.
5. Apply the mode's task approval. If the user requests changes, apply them, rerun checks, retake the snapshot, and present again.
6. If the commit policy is `after_each_task`, commit.

After all tasks:
1. If the holistic review is enabled, review all plan changes, resolve selected findings, rerun affected checks, and retake the snapshot. In Cautious mode, obtain approval of the final fixes before committing.
2. Commit per policy: `after_all_tasks` commits the completed work; `after_each_task` commits any final review fixes; `never` commits nothing.
3. Restore any pre-existing changes that were set aside and report conflicts.

</what-to-do>
