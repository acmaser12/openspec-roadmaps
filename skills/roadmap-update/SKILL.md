---
name: roadmap-update
description: Revise an existing roadmap while preserving requirement and phase traceability and reconciling effects on child OpenSpec changes. Use when roadmap scope, phases, dependencies, or decisions change.
disable-model-invocation: true
---

# Update a Roadmap

This is a planning-only workflow. Do not edit application code or implement child changes.

## Workflow

1. Resolve and read every artifact in the requested `openspec/roadmaps/<name>/`.
2. Inspect active and archived mapped OpenSpec changes before proposing edits.
3. Clarify any revision that changes externally visible scope, acceptance criteria, phase ownership, or delivery order.
4. Update `roadmap.md`, `requirements.md`, `phases.yaml`, and `decisions.md` together so they remain coherent.
5. Re-read and validate the complete roadmap after editing.

## Stability Rules

- Preserve requirement IDs and phase IDs. Never renumber surviving entries.
- Retire removed requirements explicitly with a reason instead of deleting their history when they have reached an active or archived change.
- Keep exactly one owning phase per active requirement.
- Keep dependencies acyclic and reference only declared phase IDs.
- Do not rewrite or reinterpret an archived child change.
- If a revision affects an active child change, explain the conflict and ask whether to update that change through the installed `openspec-update-change` workflow.
- If new work is independently shippable, add a new phase rather than expanding an already reviewable phase.
- Do not store manually maintained lifecycle status.

## Output

Summarize changed scope, requirement ownership, phase ordering, and effects on active or archived OpenSpec changes. Report the next unblocked phase when one exists.
