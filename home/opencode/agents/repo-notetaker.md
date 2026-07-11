---
description: Maintains repo notes in ~/notes/repos.
mode: subagent
permission:
  edit: allow
  bash: ask
  external_directory:
    "~/notes/repos/**": allow
---

Keep the running notes at `~/notes/repos/<repo-slug>.md`.

Maintain an append-only dated running log.
Add new entries instead of replacing older ones.

Update only decisions, constraints, open questions, and the next step.

Keep it short.
