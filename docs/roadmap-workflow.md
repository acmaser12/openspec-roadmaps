# Roadmap Workflow

Roadmaps coordinate large ideas that need multiple independently reviewable OpenSpec changes. They do not replace OpenSpec, act as a general backlog, or implement code.

## Model

```text
Roadmap
├── stable requirements
├── cross-phase decisions
└── dependency-aware phases
    └── one normal OpenSpec change per phase
        └── propose → apply → verify → archive
```

A **requirement ID** is a stable label for an externally meaningful outcome, such as `PAY-003`. It links the original idea to one owning phase and remains unchanged if wording or ordering changes.

A **phase** is one coherent delivery unit that can normally be implemented in one OpenSpec change and reviewed in one PR. Phases may proceed in parallel when their declared dependencies permit it; “phase” does not imply a rigid waterfall.

## Files

Roadmaps live at `openspec/roadmaps/<roadmap-name>/`:

- `roadmap.md` defines why the roadmap exists, its scope, constraints, outcomes, and success criteria.
- `requirements.md` defines stable requirement IDs, acceptance criteria, and exactly one owning phase for each requirement.
- `phases.yaml` maps phases to intended OpenSpec change names, dependencies, requirements, review boundaries, and exclusions.
- `decisions.md` records stable cross-phase decisions and rationale.

OpenSpec does not interpret this directory. The shared roadmap skills coordinate it while ordinary OpenSpec commands remain authoritative for each child change.

## Lifecycle

1. Explore a broad idea with `/opsx-explore` or `openspec-explore`.
2. If the always-on triage rule identifies multiple independently shippable outcomes, choose whether to create a roadmap.
3. Run `/roadmap-propose <description-or-name>` to create and validate roadmap artifacts only.
4. Review the requirement ownership, phase boundaries, and dependency graph.
5. Run `/roadmap-next <roadmap-name>` to prepare exactly one unblocked phase through the installed OpenSpec proposal workflow.
6. Apply, verify, and archive that child change with the standard OpenSpec workflow.
7. Run `/roadmap-status <roadmap-name>` to derive progress and identify the next action.
8. Repeat until every phase is archived.

Use `/roadmap-update` when requirements, phase boundaries, dependencies, or shared decisions change. It must reconcile effects on active changes and never rewrite archived history.

## Phase quality rules

A good phase:

- owns a coherent set of requirements;
- produces testable behavior or a testable foundation;
- has a clear review boundary and explicit exclusions;
- can ship and roll back without unfinished later phases;
- avoids mixing unrelated refactoring or opportunistic cleanup;
- declares only genuine delivery dependencies.

Split a phase again when it still contains multiple independently shippable outcomes or would create an incoherent review.

## Status is derived

`phases.yaml` deliberately contains no status field. `/roadmap-status` derives state from the mapped OpenSpec change:

- **complete**: archived;
- **active planning**: change exists but planning artifacts are incomplete;
- **ready to apply**: planning is complete and implementation remains;
- **implemented**: tasks are complete but the change is not archived;
- **ready**: no change exists and all dependencies are complete;
- **blocked**: at least one dependency is incomplete.

This avoids a second manually maintained status that can drift from OpenSpec.

## Shared agent configuration

Canonical roadmap skills and rules live in `.agent-shared/`. Relative symlinks expose the same files under both `.cursor/` and `.claude/`, so editing the canonical file updates both agents.

Generated `openspec-*` skills remain untouched. `/roadmap-next` reads and delegates to the installed `openspec-propose` skill, preserving OpenSpec's current artifact instructions, validation, and planning boundary.
