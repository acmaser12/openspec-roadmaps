---
name: roadmap-propose
description: Create a structured roadmap that decomposes a large product idea into dependency-aware, reviewable OpenSpec phases. Use when work spans multiple independently shippable changes or the user asks for a roadmap.
disable-model-invocation: true
---

# Propose a Roadmap

Create planning artifacts only. Do not create child OpenSpec changes, edit application code, or start implementation.

## Input

Accept a kebab-case roadmap name or a description of the large idea. If the intent, externally visible scope, or success criteria are materially unclear, ask before writing.

## Workflow

1. Resolve the OpenSpec root with `openspec context --json`, list active changes with `openspec list --json`, and inspect existing specs and relevant code.
2. If the roadmap name already exists under `openspec/roadmaps/`, ask whether to update it or use another name.
3. Confirm the work needs at least two independently reviewable phases. If one normal OpenSpec change is sufficient, recommend `/opsx-propose` and stop.
4. Create `openspec/roadmaps/<name>/` with all artifacts below.
5. Re-read the artifacts and validate traceability, phase boundaries, dependency order, and internal consistency.

## Artifacts

### `roadmap.md`

Use these sections:

- `## Why`
- `## Outcomes`
- `## Scope`
- `## Non-Goals`
- `## Shared Constraints`
- `## Success Criteria`

Describe initiative-level intent. Do not duplicate phase implementation plans.

### `requirements.md`

Use stable roadmap-specific IDs such as `PAY-001`. Each requirement must contain:

- a normative, externally meaningful requirement;
- testable acceptance criteria;
- exactly one owning phase ID.

IDs never change because wording or ordering changes. Retire an obsolete ID explicitly; never renumber surviving requirements.

### `phases.yaml`

Use this shape:

```yaml
roadmap: paycheck-planning
phases:
  - id: P1
    name: Core paycheck calculation
    change: add-paycheck-tax-calculator
    goal: Produce a transparent gross-to-net estimate.
    depends_on: []
    requirements:
      - PAY-001
      - PAY-002
    review_boundary: One independently testable and reviewable delivery.
    excluded:
      - Allocation templates
```

Do not store lifecycle status; `/roadmap-status` derives it from OpenSpec.

### `decisions.md`

Record cross-phase decisions, assumptions, and constraints. Give decisions stable IDs such as `D-001`, including rationale and affected phases.

## Phase Rules

- Each phase maps to exactly one intended OpenSpec change and normally one PR.
- Prefer vertical, user-observable behavior over frontend/backend/test-only layers.
- A foundation phase is allowed only with a concrete, testable completion boundary.
- Every phase must be independently reviewable, verifiable, shippable, and reversible without requiring unfinished later phases.
- Dependencies must form an acyclic graph and reflect true delivery prerequisites.
- Every requirement has exactly one owner and appears in that phase's `requirements` list.
- Shared decisions may affect multiple phases but must not create duplicate requirement ownership.
- If a phase still contains multiple independently shippable outcomes, split it again.

## Output

Report the roadmap path, phase order, requirement coverage, and unblocked first phase. Prompt the user to review the roadmap, then invoke `/roadmap-next` when ready.
