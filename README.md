# Taches Windsurf Cascade Resources

Windsurf-compatible port of the Taches resource set.

This version is organized around:

- `.windsurf/workflows/` (workflow entry points)
- `.windsurf/skills/` (skill content)
- `.windsurf/rules/` (global guidance)

## Installation

This repo is manual-install only. No marketplace/plugin steps.

### Option 1: Global install (recommended)

Installs workflows, skills, and rules globally so they are available in **every project** on your machine — no per-project copying needed. This is the Windsurf equivalent of Claude CC's `~/.claude/commands/` install.

#### PowerShell (Windows)

```powershell
# Workflows
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf\workflows\*" -Destination "$env:USERPROFILE\.codeium\windsurf\global_workflows\" -Recurse -Force

# Skills
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf\skills\*" -Destination "$env:USERPROFILE\.codeium\windsurf\skills\" -Recurse -Force

# Rules (optional)
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf\rules\*" -Destination "$env:USERPROFILE\.codeium\windsurf\global_rules\" -Recurse -Force
```

#### Bash (macOS/Linux)

```bash
# Workflows
cp -R ./taches-windsurf-cascade-resources/.windsurf/workflows/* ~/.codeium/windsurf/global_workflows/

# Skills
cp -R ./taches-windsurf-cascade-resources/.windsurf/skills/* ~/.codeium/windsurf/skills/

# Rules (optional)
cp -R ./taches-windsurf-cascade-resources/.windsurf/rules/* ~/.codeium/windsurf/global_rules/
```

Restart Windsurf after copying for discovery.

---

### Option 2: Project-local install

Copy the `.windsurf` folder into a specific project root only.

#### PowerShell (Windows)

```powershell
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf" -Destination "<your-project>\.windsurf" -Recurse -Force
```

#### Bash (macOS/Linux)

```bash
cp -R ./taches-windsurf-cascade-resources/.windsurf <your-project>/.windsurf
```

Restart Windsurf/Cascade after copy.

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

