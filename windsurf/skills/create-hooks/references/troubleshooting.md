# Troubleshooting

Common issues and solutions when working with Windsurf Cascade hooks.

> **Windows**: Use `.windsurf/hooks/py` launcher instead of `python3` — see [Hook Configuration Reference](./matchers.md#cross-platform-python-launcher).

---

## Hook Not Triggering

### Symptom
Hook never executes even when the expected event occurs.

### Steps

**1. Check hook file location**

Hooks must be in one of:
- Workspace: `.windsurf/hooks.json`
- User: `~/.codeium/windsurf/hooks.json`

Verify:
```powershell
# Windows
Get-Content .windsurf/hooks.json
```
```bash
# macOS/Linux
cat .windsurf/hooks.json
```

**2. Validate JSON syntax**

Invalid JSON is silently ignored — hooks won't fire:

```powershell
# Windows
Get-Content .windsurf/hooks.json | ConvertFrom-Json
```
```bash
# macOS/Linux
python3 -m json.tool .windsurf/hooks.json
```

**3. Verify the event name is correct**

Event names are lowercase with underscores. Common mistakes:

❌ Wrong (Claude Code style)
```json
{ "PreToolUse": [...] }
```

✅ Correct (Windsurf style)
```json
{ "pre_run_command": [...] }
```

Full list: `pre_read_code`, `post_read_code`, `pre_write_code`, `post_write_code`, `pre_run_command`, `post_run_command`, `pre_mcp_tool_use`, `post_mcp_tool_use`, `pre_user_prompt`, `post_cascade_response`, `post_cascade_response_with_transcript`, `post_setup_worktree`

**4. Trigger the right Cascade action**

Hooks only fire when Cascade performs the corresponding action. `pre_run_command` only fires when Cascade runs a terminal command — not when you run commands yourself in the terminal.

---

## Script Not Executing

### Symptom
Hook is configured but script errors or doesn't run.

### Steps

**1. Test the script manually with sample input**

```bash
echo '{"agent_action_name":"pre_run_command","trajectory_id":"test","execution_id":"test","timestamp":"2025-01-01T00:00:00Z","tool_info":{"command_line":"echo hello","cwd":"/tmp"}}' | python3 .windsurf/hooks/your_script.py
```

**2. Check executable permissions (macOS/Linux)**

```bash
chmod +x .windsurf/hooks/your_script.py
# or for shell scripts:
chmod +x .windsurf/hooks/your_script.sh
```

**3. Check shebang line**

Script files must have a correct shebang:
```python
#!/usr/bin/env python3
```
```bash
#!/bin/bash
```

**4. Verify the command path**

Use paths relative to workspace root or absolute paths. `~` is **not** expanded:

❌ Won't work
```json
{ "command": "~/hooks/script.py" }
```

✅ Correct
```json
{ "command": "/Users/yourname/hooks/script.py" }
```

✅ Also correct (relative to workspace root)
```json
{ "command": "python3 .windsurf/hooks/script.py" }
```

---

## Hook Blocks Everything

### Symptom
Pre-hook blocks all actions, even safe ones.

### Cause
Logic error — script exits with code `2` unconditionally, or has an unhandled exception that causes unexpected exit.

### Solutions

**Add a default allow at the end:**
```python
import sys, json

data = json.loads(sys.stdin.read())
cmd = data.get("tool_info", {}).get("command_line", "")

if "rm -rf /" in cmd:
    print("Blocked: dangerous command", file=sys.stderr)
    sys.exit(2)

sys.exit(0)  # ← Always allow unless explicitly blocked
```

**Wrap in try/except to prevent crashes blocking actions:**
```python
import sys, json

try:
    data = json.loads(sys.stdin.read())
    cmd = data.get("tool_info", {}).get("command_line", "")
    if "rm -rf /" in cmd:
        print("Blocked", file=sys.stderr)
        sys.exit(2)
except Exception:
    pass  # On error, allow action to proceed

sys.exit(0)
```

---

## Hook Output Not Visible

### Symptom
Hook runs but nothing appears in the Cascade UI.

### Solutions

**Set `show_output: true` in config:**
```json
{
  "hooks": {
    "pre_run_command": [
      {
        "command": "python3 .windsurf/hooks/check.py",
        "show_output": true
      }
    ]
  }
}
```

**Write to stdout (not only stderr) for informational messages:**
```python
print("Hook ran successfully")        # visible if show_output: true
print("Blocked: reason", file=sys.stderr)  # shown when blocking
```

**Note**: `show_output` does not apply to `pre_user_prompt` or `post_cascade_response`.

---

## Pre-hook Not Blocking

### Symptom
Pre-hook runs but action is not blocked.

### Cause
Script exits with a non-2 code, or only `post_` hooks are used (post-hooks cannot block).

### Solutions

**Use exit code `2` to block (not `1` or any other code):**
```python
sys.exit(2)  # ← This blocks
sys.exit(1)  # ← This does NOT block (action proceeds)
```

**Verify you are using a `pre_` event, not `post_`:**

Only these events can block:
- `pre_read_code`
- `pre_write_code`
- `pre_run_command`
- `pre_mcp_tool_use`
- `pre_user_prompt`

---

## Permission Errors

### Symptom
Script can't read files or execute commands.

### Solutions

**Make scripts executable (macOS/Linux):**
```bash
chmod +x .windsurf/hooks/*.py
chmod +x .windsurf/hooks/*.sh
```

**Use absolute paths for files outside workspace:**
```python
import os
# Read a file outside the project
with open("/absolute/path/to/config.txt") as f:
    config = f.read()
```

---

## Debugging Workflow

**Step 1**: Set `"show_output": true` on the hook during development

**Step 2**: Test the script directly in terminal with sample input
```bash
echo '{"agent_action_name":"pre_run_command","trajectory_id":"t","execution_id":"e","timestamp":"2025-01-01T00:00:00Z","tool_info":{"command_line":"npm install","cwd":"/tmp"}}' | python3 .windsurf/hooks/your_script.py
echo "Exit code: $?"
```

**Step 3**: Add debug logging to your script
```python
import sys, json

data = json.loads(sys.stdin.read())

# Write debug info to a log file
with open("/tmp/hook-debug.log", "a") as f:
    f.write(f"Event: {data.get('agent_action_name')}\n")
    f.write(f"tool_info: {data.get('tool_info')}\n")

sys.exit(0)
```

**Step 4**: Validate your JSON config
```bash
python3 -m json.tool .windsurf/hooks.json
```

**Step 5**: Check that hooks are merged correctly — system hooks, user hooks, and workspace hooks are all active simultaneously. If a system-level hook is blocking, it will block even if your workspace hook allows.
