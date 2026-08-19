---
description: Detect roadmap-sized work before creating an oversized OpenSpec change
alwaysApply: true
---

# Roadmap Triage

Before scaffolding a new OpenSpec change, assess whether the idea is one coherent reviewable change or a roadmap containing multiple phases.

Roadmap signals include:

- multiple independently shippable outcomes;
- several capability areas or architectural boundaries;
- explicit sequencing between deliverables;
- work likely to require multiple focused PRs;
- a proposal, specification, or task list too large for one coherent review;
- portions that can be verified and archived independently.

Use judgment, not rigid numeric thresholds.

During `/opsx-explore`, `/opsx:explore`, or `openspec-explore`, continue discovery and explain with concrete evidence when the idea appears roadmap-sized. Offer `/roadmap-propose`.

During `/opsx-propose`, `/opsx:propose`, or `openspec-propose`, stop before `openspec new change` when the request is materially roadmap-sized. Ask whether to create a roadmap or deliberately continue as one change.

Never create a roadmap without user approval. Do not force a roadmap onto an ordinary small or medium change. Roadmaps coordinate related OpenSpec changes; they are not a general backlog.
