---
name: planning
description: Plan a design or decision. Use when the user wants to stress-test a plan before building, or uses any 'planning' trigger phrases.
---

# Planning

Interview the user on the plan until there is shared understanding.

Rules:

- Be direct, concise, and factual.
- Ask one question at a time.
- Wait for the user's answer before continuing.
- For each question, include a recommended answer.
- Resolve dependencies before moving to the next branch.
- If codebase inspection can answer the question, inspect the codebase first.

If the planning spans multiple turns, use the `planning-notetaker` agent to keep notes under `~/notes/planning`.

If the work is codebase-specific, use the `repo-notetaker` agent to keep notes under `~/notes/repos`.

Focus areas:

- Goal and success criteria
- Scope and non-goals
- Constraints and tradeoffs
- Data flow and state ownership
- Failure modes and edge cases
- Implementation order and rollout
- Testing and verification
- Operational concerns
