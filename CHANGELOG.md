# Changelog

All notable changes to this project will be documented in this file.

---

## [v0.1] — 2026-04-02

Initial Windsurf-compatible release. Full port of [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources) from Claude Code to Windsurf Cascade, with all compatibility issues resolved.

### Added

- **39 workflows** across meta-prompting, todo management, context handoff, create/audit extensions, thinking models, research, and deep analysis categories
- **10 skills** covering project planning, MCP server creation, agent skills, meta-prompts, slash commands, subagents, hooks, debugging, Ralph setup, and The Pirate Bay
- **`install.ps1`** — PowerShell installer for Windows; supports `install`, `update`, `uninstall`; invokable as a one-liner via `irm ... | iex`
- **`install.sh`** — Bash installer for macOS/Linux; supports `install`, `update`, `uninstall`; invokable as a one-liner via `curl ... | bash`
- Both installers target `~/.codeium/windsurf/` (global), save a manifest for clean uninstall, and pull files directly from GitHub without requiring a local clone
- **`the-pirate-bay` skill** — search The Pirate Bay via apibay.org JSON API, extract magnet links, browse top torrents by category

### Changed

- **Renamed `.windsurf/` → `windsurf/`** — Source folder no longer uses dot-prefix, so opening this repo in Windsurf no longer auto-loads these workflows and skills as active config. Install globally via the installer scripts; do not rely on the local folder loading.

### Fixed — Windsurf Compatibility

#### Structural fixes
- `competitive.md`, `deep-dive.md` — Added missing `<intake_gate>` opening XML tags (broken XML structure)

#### Path corrections
- `check-todos.md` — Replaced `.claude/skills/` with `.windsurf/skills/`
- `heal-skill.md` — Updated `SKILL_DIR` from `./skills/` to `.windsurf/skills/`
- `debug-like-expert/SKILL.md` — Replaced `~/.claude/skills/expertise/` with `~/.codeium/windsurf/skills/expertise/`
- `create-plans/SKILL.md` — Same path replacement in 3 locations
- `core.md` rule — Fixed `.prompts/` → `prompts/` to match actual folder convention

#### Typos
- `whats-next.md` — Fixed `gotcas` → `gotchas`

#### README fixes
- Updated skill count from 9 → 10
- Added `the-pirate-bay` skill entry

### Rewritten — `create-hooks` Skill (Claude Code → Windsurf)

The entire `create-hooks` skill was rewritten from Claude Code hooks to the Windsurf Cascade hooks API:

- **`SKILL.md`** — Full rewrite: correct config file paths (`.windsurf/hooks.json`, `~/.codeium/windsurf/hooks.json`), Windsurf event names, exit-code-based blocking model (exit `2` = block), removed Claude Code-specific concepts (`type: "prompt"`, `matcher`, `PreToolUse`, `PostToolUse`, etc.)

- **`references/hook-types.md`** — Rewritten with all 12 Windsurf hook events and their `tool_info` input schemas: `pre_read_code`, `post_read_code`, `pre_write_code`, `post_write_code`, `pre_run_command`, `post_run_command`, `pre_mcp_tool_use`, `post_mcp_tool_use`, `pre_user_prompt`, `post_cascade_response`, `post_cascade_response_with_transcript`, `post_setup_worktree`

- **`references/input-output-schemas.md`** — Rewritten with Windsurf common input fields (`agent_action_name`, `trajectory_id`, `execution_id`, `timestamp`, `tool_info`), per-event `tool_info` schemas, and output model (exit codes only, stderr for messages)

- **`references/examples.md`** — Rewritten with 7 working Windsurf examples: audit logging, file access restriction, dangerous command blocking, auto-formatting, prompt validation, response logging, worktree init, and multi-hook chaining

- **`references/matchers.md`** — Repurposed as **Hook Configuration Reference**: config file locations, config structure, field reference, multiple hooks per event, in-script filtering (replaces non-existent matchers concept), JSON validation, recommended project layout

- **`references/troubleshooting.md`** — Rewritten with Windsurf-specific debugging: correct event name format, exit code 2 requirement for blocking, `show_output` field, `~` path expansion limitation, and step-by-step debugging workflow

---

## Notes

### Installation recommendation

**Global install is strongly recommended** over project-local install. These workflows and skills are general-purpose tools — installing them in every individual project's `.windsurf/` folder creates noise and duplication. Install once globally and they are available in every project.

See [README.md — Global install](./README.md#option-2-global-install-use-in-every-project) for instructions.
