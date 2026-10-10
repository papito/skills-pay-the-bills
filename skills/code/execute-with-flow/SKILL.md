---
name: execute-with-flow
description: Execute a plan but with with a meat bag in the loop
---

<what-to-do>

Invoke the plan:execute skill with one major difference. The user will be in the loop for each change. For each:

1. Explain what you are about to do.
2. Show the diff.
3. Ask the user to: Proceed, Ask a question about the code, Make a change.
4. If the user asks for a change, make it and go to point 1 again, in a loop until the user is satisfied with the results.
5. If the user asks a question, answer the question and present the menu again.
6. Move on to the change.

IMPORTANT: for efficiency, if the changes are very similar and repetitive, process them in a batch as one atomic change.

</what-to-do>
