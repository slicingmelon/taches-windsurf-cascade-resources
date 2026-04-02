# Taches Windsurf Cascade Resources

Windsurf-compatible port of the Taches resource set.

This version is organized around:

- `.windsurf/workflows/` (workflow entry points)
- `.windsurf/skills/` (skill content)
- `.windsurf/rules/` (global guidance)

## Manual Installation (Windsurf)

This repo is manual-install only. No marketplace/plugin steps.

### Project-local install (recommended)

Copy the `.windsurf` folder from this repo into your target project root.

#### PowerShell (Windows)

```powershell
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf" -Destination "<your-project>\.windsurf" -Recurse -Force
```

#### Bash (macOS/Linux)

```bash
cp -R ./taches-windsurf-cascade-resources/.windsurf <your-project>/.windsurf
```

After copy, restart Windsurf/Cascade for discovery.

## Structure

```text
taches-windsurf-cascade-resources/
├── .windsurf/
│   ├── workflows/    # Converted workflow skeletons from original commands/
│   ├── skills/       # Skill content ported for Windsurf usage
│   └── rules/        # Base operating rules
├── commands/         # Original Claude command definitions (retained for reference)
├── skills/           # Original source skill definitions
└── agents/           # Original auditor agents (reference material)
```

## What was converted

- Original command intents were converted into workflow skeletons under `.windsurf/workflows/`.
- Skills were mirrored into `.windsurf/skills/`.
- A base rules file was added at `.windsurf/rules/core.md`.

## Important note

These are skeleton conversions to make the resource pack Windsurf-discoverable quickly.

Some workflow bodies still contain Claude-specific phrasing (for example, references to subagents or legacy command arguments). Treat them as migration scaffolds and refine per workflow as needed.
