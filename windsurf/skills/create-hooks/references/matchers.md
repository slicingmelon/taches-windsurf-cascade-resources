# Hook Configuration Reference

Complete guide to configuring Windsurf Cascade hooks.

> **Note**: Windsurf hooks do NOT have a "matcher" concept. Each hook event fires for all occurrences of that event. If you need event-specific filtering (e.g., only act on Python files), implement that logic inside your script.

> **Windows note**: Replace `python3` with `python` in all examples below.

---

## Configuration File Locations

Hooks are loaded from all three locations and merged (system → user → workspace):

| Scope | Path |
|-------|------|
| **Workspace** | `.windsurf/hooks.json` (version-controlled, project-specific) |
| **User** | `~/.codeium/windsurf/hooks.json` (personal preferences) |
| **System (macOS)** | `/Library/Application Support/Windsurf/hooks.json` |
| **System (Linux/WSL)** | `/etc/windsurf/hooks.json` |
| **System (Windows)** | `C:\ProgramData\Windsurf\hooks.json` |

---

## Config Structure

```json
{
  "hooks": {
    "<event_name>": [
      {
        "command": "your command here",
        "show_output": true,
        "working_directory": "/optional/path"
      }
    ]
  }
}
```

### Hook entry fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `command` | string | Yes | Shell command to execute |
| `show_output` | boolean | No | Show hook stdout/stderr in Cascade UI. Default: false |
| `working_directory` | string | No | Directory to run command from. Defaults to workspace root |

### Notes on `working_directory`
- Relative paths resolve from workspace root
- Absolute paths are supported
- `~` expansion is **not** supported — use absolute paths for home-relative scripts
- In multi-repo workspaces, default is the root of the repo being worked on

---

## Multiple hooks per event

You can list multiple hooks for the same event. They execute in order:

```json
{
  "hooks": {
    "pre_run_command": [
      {
        "command": "python3 .windsurf/hooks/log.py",
        "show_output": false
      },
      {
        "command": "python3 .windsurf/hooks/block_dangerous.py",
        "show_output": true
      }
    ]
  }
}
```

All hooks in the list run regardless of whether one blocks. The action is blocked if **any** hook exits with code `2`.

---

## Filtering inside scripts

Since there are no matchers, filter by event data inside your script:

```python
import sys, json

data = json.loads(sys.stdin.read())
file_path = data.get("tool_info", {}).get("file_path", "")

# Only act on Python files
if not file_path.endswith(".py"):
    sys.exit(0)

# Your logic here...
```

---

## Validating your config

Always validate your JSON before relying on hooks:

```bash
# PowerShell (Windows)
Get-Content .windsurf/hooks.json | ConvertFrom-Json

# macOS/Linux
python3 -m json.tool .windsurf/hooks.json

# Or with jq
jq . .windsurf/hooks.json
```

Invalid JSON is silently ignored — hooks won't fire if the config is malformed.

---

## Recommended project layout

Keep hook scripts alongside the config for portability:

```
.windsurf/
  hooks.json              ← config
  hooks/
    py                    ← cross-platform Python launcher (see below)
    log_input.py          ← logging script
    block_dangerous.py    ← safety script
    format_on_save.py     ← formatter script
    restrict_access.py    ← access control script
```

Reference scripts using the launcher:

```json
{
  "command": ".windsurf/hooks/py .windsurf/hooks/block_dangerous.py"
}
```

### Cross-platform Python launcher

Create `.windsurf/hooks/py` (macOS/Linux) and `.windsurf/hooks/py.cmd` (Windows) so hooks work on all platforms without hardcoding `python3` or `python`.

**`.windsurf/hooks/py`** (macOS/Linux — make executable with `chmod +x`):
```bash
#!/usr/bin/env sh
# Finds python3 or python and runs the given script with it
if command -v python3 >/dev/null 2>&1; then
    exec python3 "$@"
elif command -v python >/dev/null 2>&1; then
    exec python "$@"
else
    echo "Error: Python not found. Install Python 3." >&2
    exit 1
fi
```

**`.windsurf/hooks/py.cmd`** (Windows):
```bat
@echo off
where python3 >nul 2>&1
if %errorlevel% == 0 (
    python3 %*
    exit /b %errorlevel%
)
where python >nul 2>&1
if %errorlevel% == 0 (
    python %*
    exit /b %errorlevel%
)
echo Error: Python not found. Install Python 3. 1>&2
exit /b 1
```

Windsurf runs hooks through the system shell — on Windows it uses `cmd.exe`, so `.cmd` files are picked up automatically when you call `.windsurf/hooks/py` (Windows resolves `py` → `py.cmd`).

> **Alternative**: If you know your team is Windows-only, just use `python` everywhere. If macOS/Linux only, use `python3`.

### Without a launcher

If you prefer not to use a launcher, use the shell's built-in fallback directly in `hooks.json`:

```json
{
  "command": "python3 .windsurf/hooks/script.py || python .windsurf/hooks/script.py"
}
```
