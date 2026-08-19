# OpenSpec Roadmaps

Agent skills and an always-on triage rule that break large OpenSpec work into dependency-aware, independently reviewable phases.

This pack does not replace OpenSpec. Each phase still becomes a normal OpenSpec change (`propose` → `apply` → `verify` → `archive`). Generated `openspec-*` skills stay in the consuming project, installed by the OpenSpec CLI.

## Install

This repository is private, so install from a local clone:

```bash
git clone git@github.com:adammaser/openspec-roadmaps.git ~/dev/openspec-roadmaps
cd /path/to/openspec-project
~/dev/openspec-roadmaps/install.sh
```

The target must be a git repository with an `openspec/` directory. Use `--force` only if you intentionally want to install before OpenSpec is present:

```bash
~/dev/openspec-roadmaps/install.sh --target /path/to/project --force
```

Re-running the installer updates pack-owned files and recreates the same symlinks. It does not touch generated `openspec-*` skills or existing `openspec/roadmaps/<name>/` directories.

Commit the installed files in the consuming project so Cursor and Claude pick them up for everyone who clones it.

## What it installs

Canonical copies live in `.agent-shared/`. Relative symlinks expose them to both agents:

```text
.agent-shared/
├── docs/roadmap-workflow.md
├── openspec-roadmaps.source
├── rules/roadmap-triage.md
└── skills/
    ├── roadmap-next/
    ├── roadmap-propose/
    ├── roadmap-status/
    └── roadmap-update/
.cursor/skills/roadmap-*          -> ../../.agent-shared/skills/roadmap-*
.claude/skills/roadmap-*          -> ../../.agent-shared/skills/roadmap-*
.cursor/rules/roadmap-triage.mdc  -> ../../.agent-shared/rules/roadmap-triage.md
.claude/rules/roadmap-triage.md   -> ../../.agent-shared/rules/roadmap-triage.md
openspec/roadmaps/README.md       # created only if missing
```

`.agent-shared/openspec-roadmaps.source` records the pack repo, commit, and install time.

## Skills

| Skill | Use |
| --- | --- |
| `/roadmap-propose` | Create roadmap artifacts only (`roadmap.md`, `requirements.md`, `phases.yaml`, `decisions.md`) |
| `/roadmap-next` | Prepare exactly one unblocked phase through the installed `openspec-propose` skill |
| `/roadmap-status` | Derive progress from mapped OpenSpec changes |
| `/roadmap-update` | Revise an existing roadmap without rewriting archived history |

The always-on triage rule stops oversized `/opsx-propose` / `openspec-propose` work and offers `/roadmap-propose` instead.

See [docs/roadmap-workflow.md](docs/roadmap-workflow.md) for the model, artifact rules, and lifecycle.

## Fallback

`npx skills add` can copy the `skills/` directory, but it will not install the triage rule or the dual-agent `.agent-shared/` symlink layout. Prefer `install.sh`.
