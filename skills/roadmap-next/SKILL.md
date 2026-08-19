---
name: roadmap-next
description: Select or resume the next unblocked phase in a roadmap and prepare exactly one standard OpenSpec change. Use when the user wants to continue roadmap delivery.
disable-model-invocation: true
---

# Prepare the Next Roadmap Phase

Coordinate planning only. Never apply code, archive a change, or prepare more than one phase per invocation.

## Workflow

1. Resolve the requested roadmap under `openspec/roadmaps/`. If none is named and multiple exist, ask which one to use.
2. Read `roadmap.md`, `requirements.md`, `phases.yaml`, and `decisions.md`.
3. Run `openspec list --json`, inspect relevant active change statuses, and inspect `openspec/changes/archive/` to derive phase state:
   - `complete`: the mapped change is archived;
   - `active`: the mapped change exists under active changes;
   - `ready`: no mapped change exists and every dependency is complete;
   - `blocked`: at least one dependency is incomplete.
4. Validate phase IDs, requirement ownership, dependency references, and acyclicity before continuing.
5. If a phase is already active:
   - if its planning artifacts are incomplete, resume the installed `openspec-propose` workflow for that change;
   - if planning is complete, report that it is ready for `/opsx-apply` and stop.
6. Otherwise select one ready phase. If several are ready and there is no unambiguous declared order, ask the user to choose.
7. Read the installed `openspec-propose` skill and follow it in full to create exactly the selected phase's standard OpenSpec proposal, specs, design, and tasks.

## Child Change Context

Pass the standard proposal workflow only:

- the phase goal and review boundary;
- its owned requirement IDs and acceptance criteria;
- applicable shared decisions and constraints;
- completed dependency outcomes;
- explicit exclusions from `phases.yaml`;
- the roadmap name and phase ID for traceability.

The child change must remain self-contained enough to apply and review without rereading the full roadmap. Preserve the standard OpenSpec artifact instructions and strict validation.

## Guardrails

- Do not duplicate the OpenSpec proposal procedure in this skill; delegate to the installed skill so OpenSpec updates remain authoritative.
- Do not mark status in `phases.yaml`; status is derived.
- Do not silently change roadmap scope while preparing a phase. Use `/roadmap-update` first when the roadmap is inconsistent.
- Do not include requirements owned by later phases merely because they are related.
- Stop after planning. Applying the selected change requires a separate user request.
