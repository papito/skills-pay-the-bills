---
name: quiz-me-on-your-code
description: Quiz the user on their understanding of code that Claude recently wrote or modified. Use when the user wants to verify they understand Claude-generated code before moving on.
---

<what-to-do>

Quiz me on my understanding of the code you just wrote or modified.

First, identify the code changes from this conversation. If there are no recent changes, ask me which files or changes to quiz on.

Then, ask me targeted questions one at a time — covering intent, behavior, edge cases, and how the code fits into the broader codebase. Start with high-level "what does this do and why" questions, then drill into specifics.

For each question, wait for my answer before continuing. After I answer, tell me if I'm right, partially right, or wrong — and briefly explain the correct answer with references to the actual code.

If I'm struggling, give hints rather than answers. If I'm breezing through, escalate to harder questions about edge cases, failure modes, or interactions with the rest of the system.

Keep going until we've covered all significant aspects of the changes, then give me a summary of how I did.

</what-to-do>
