## Important!

### Project-specific Notes

Avoid document rot: always update AGENTS.md, CLAUDE.md, and ARCHITECTURE.md – if any of these exist – if the code being change, removed, or added affects these files

Run "make lint" after "make test" runs successfully to check for formatting and style issues.

Do NOT run "make watch" or "make run" while developing.

If the pipeline components get added, removed, or moved around, update the ARCHITECTURE.md file

### Code Style and Quality

Analyze surrounding comments when adding new features or updating existing code – update the comments if necessary.

Factor our code into functions if there are two or more similar instances of logic.

Write as little code as possible while maintaing clarity and readability. In the case of CSS, this is especially true. Solve the core problem with the least number of new properties and make no assumptions about what the user wants (color, padding, etc.)

Analyze surrounding comments and fix them if necessary.

Do not redundantly comment obvious code but always comment code that's complex (for example, long functional one-liners)
