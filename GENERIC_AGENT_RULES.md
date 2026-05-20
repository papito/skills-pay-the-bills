Factor our code into functions if there are two or more similar instances of logic.

Write as little code as possible. In case of CSS, this is especially true - solve the core problem with least amount of new properties and make no assumptions about what the user wants (color, padding, etc.)

Analyze surrounding comments and fix them if necessary.

Do not redundatly comment obvious code but always comment code that's complex (for example, long functional one-liners)

Avoid document rot: always update AGENTS.md, CLAUDE.md, and ARCHITECTURE.md - if any of these exist - if the code being change, removed, or added affects these files
