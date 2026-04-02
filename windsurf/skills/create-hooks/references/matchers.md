# Hook Configuration Reference

Complete guide to configuring Windsurf Cascade hooks.

> **Note**: Windsurf hooks do NOT have a "matcher" concept. Each hook event fires for all occurrences of that event. If you need event-specific filtering (e.g., only act on Python files), implement that logic inside your script.

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
    log_input.py          ← logging script
    block_dangerous.py    ← safety script
    format_on_save.py     ← formatter script
    restrict_access.py    ← access control script
```

Reference scripts with relative paths from workspace root:

```json
{
  "command": "python3 .windsurf/hooks/block_dangerous.py"
}
```
