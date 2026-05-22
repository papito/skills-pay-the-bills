## Important!

### Project-specific Notes

Avoid document rot: always update AGENTS.md, CLAUDE.md, and ARCHITECTURE.md – if any of these exist – if the related code is being changed, removed, or added.

Always surrounding code comments when adding new features or updating existing code – update the comments if necessary.

Do not comment code where the information is highly redundant. Always comment code that's complex and may be hard to follow (for example, long functional one-liners).

Execute "make lint" after a "make test" run to check for formatting and style issues.

### Code Style and Quality

#### Scala/Python/Go/JavaSript

Factor our code into functions if there are two or more similar instances of logic.

Write as little code as possible while maintaining clarity and readability. 


### CSS/HTML

Use the least number of properties and as little markup as needed to address a task.

Make no assumptions about what the user wants (color, padding, etc.). If not sure - leave it at defaults.

Heavily prefer CSS Grid and Flexbox over floats, positioning, and tables

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
