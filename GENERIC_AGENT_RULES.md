## Important!

### General notes

Avoid documentation drift. When related code is added, changed, or removed, update AGENTS.md, CLAUDE.md, and ARCHITECTURE.md if they exist.

When adding features or modifying existing behavior, review nearby code comments and update them where needed.

Avoid comments that merely restate the code. Add comments when they clarify complex or non-obvious logic, such as dense functional one-liners.

After running make test, run make lint to catch formatting and style issues.

Code Style and Quality

### Server-side

Extract shared logic into functions when the same or similar logic appears more than once.

Write the smallest amount of code that preserves clarity, readability, and maintainability.

### Front-end

Use the fewest props and the least markup needed to accomplish the task.

Do not assume aesthetic preferences such as color, spacing, or padding unless they are specified.

Strongly prefer CSS Grid and Flexbox over floats, manual positioning, or table-based layouts.

Identify the main CSS file and use :root variables. Example: 

```css
:root {
    color-scheme: light dark;

    --background-color: #363636;
    --background-form-color: #363535;
    --background-secondary-color: rgb(56, 56, 65);
    --background-tertiary-color: rgb(75, 75, 87);
}
```
