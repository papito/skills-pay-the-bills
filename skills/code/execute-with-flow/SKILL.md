---
name: execute-with-flow
description: Execute a plan but with with a meat bag in the loop
---

<what-to-do>

Invoke the plan:execute skill with one major difference. For every code change about to be made:

1. Show the diff
2. Present short explanation of the code's intent
3. Ask the user to proceed or change something
4. If the user asks for a change, make it and go to point 1 again, in a loop until the user is satisfied with the results.
5. Move on to the next diff.

</what-to-do>
