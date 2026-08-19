---
name: roadmap-status
description: Report dependency-aware status and consistency for a structured roadmap by comparing its phases with active and archived OpenSpec changes. Use for roadmap progress or readiness questions.
disable-model-invocation: true
---

# Show Roadmap Status

This is a read-only workflow. Never edit roadmap artifacts, OpenSpec changes, or application code.

## Workflow

1. Resolve the requested roadmap under `openspec/roadmaps/`. If none is named and multiple exist, ask which one to inspect.
2. Read all four roadmap artifacts.
3. Run `openspec list --json`; run `openspec status --change "<name>" --json` for mapped active changes; inspect `openspec/changes/archive/` for mapped archived changes.
4. Derive each phase state:
   - `complete`: mapped change archived;
   - `active-planning`: mapped active change has incomplete planning artifacts;
   - `ready-to-apply`: mapped active change has complete planning artifacts and incomplete tasks;
   - `implemented`: mapped active change has all tasks complete but is not archived;
   - `ready`: no mapped change and all dependencies complete;
   - `blocked`: no mapped change and at least one dependency incomplete.
5. Identify the next actionable phase or action.

## Consistency Checks

Report:

- missing or duplicate phase IDs and change names;
- missing dependencies or dependency cycles;
- requirement IDs with no owner, multiple owners, or mismatched phase mappings;
- active or archived mapped changes that disagree with the roadmap;
- active roadmap-related changes not represented in `phases.yaml`;
- phases marked ready whose prerequisites are not actually archived.

Do not repair drift. Recommend `/roadmap-update` or the appropriate OpenSpec action.

## Output

Summarize overall progress, then list phases in dependency order with state, mapped change, blockers, and requirement IDs. Keep the result concise and call out inconsistencies before recommending the next action.
