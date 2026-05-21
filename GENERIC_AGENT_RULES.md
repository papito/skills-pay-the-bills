## Important!

### Project-specific Notes

Avoid document rot: always update AGENTS.md, CLAUDE.md, and ARCHITECTURE.md – if any of these exist – if the code being change, removed, or added affects these files

Run "make lint" after "make test" runs successfully to check for formatting and style issues.

Do NOT run "make watch" or "make run" while developing.

If the pipeline components get added, removed, or moved around, update the ARCHITECTURE.md file

### Code Style and Quality

#### Scala/Python/Go/JavaSript
Analyze surrounding comments when adding new features or updating existing code – update the comments if necessary.

Factor our code into functions if there are two or more similar instances of logic.

Write as little code as possible while maintaining clarity and readability. 

Do not redundantly comment obvious code but always comment code that's complex (for example, long functional one-liners) or logic that may be deemed non-trivial by someone less experienced.

### CSS/HTML

Solve the core task with the least number of properties and as little markup as needed. 

Make no assumptions about what the user wants (color, padding, etc.)

Heavily prefer CSS Grid and Flexbox over floats and positioning.

Identify the main CSS file and use :root variables if an additional value is needed for a task: 

```css
:root {
    color-scheme: light dark;

    --background-color: #363636;
    --background-form-color: #363535;
    --background-secondary-color: rgb(56, 56, 65);
    --background-tertiary-color: rgb(75, 75, 87);
}
```
