# Working Examples

Real-world Windsurf Cascade hook configurations ready to use.

All hooks go in `.windsurf/hooks.json` (workspace) or `~/.codeium/windsurf/hooks.json` (user).
All hook scripts receive JSON via stdin and communicate via exit codes.

> **Windows note**: Replace `python3` with `python` in all commands below.

---

## Logging All Cascade Actions

Track every action for auditing.

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "post_read_code": [{ "command": "python3 .windsurf/hooks/log_input.py", "show_output": false }],
    "post_write_code": [{ "command": "python3 .windsurf/hooks/log_input.py", "show_output": false }],
    "post_run_command": [{ "command": "python3 .windsurf/hooks/log_input.py", "show_output": false }],
    "post_cascade_response": [{ "command": "python3 .windsurf/hooks/log_input.py" }]
  }
}
```

`log_input.py`:
```python
#!/usr/bin/env python3
import sys, json
data = json.loads(sys.stdin.read())
with open("cascade-audit.log", "a") as f:
    f.write(json.dumps(data, separators=(',', ':')) + "\n")
```

---

## Restricting File Access

Prevent Cascade from reading files outside a specific directory.

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "pre_read_code": [
      {
        "command": "python3 .windsurf/hooks/restrict_access.py",
        "show_output": true
      }
    ]
  }
}
```

`restrict_access.py`:
```python
#!/usr/bin/env python3
import sys, json

ALLOWED_PREFIX = "/path/to/my-project/"

data = json.loads(sys.stdin.read())
file_path = data.get("tool_info", {}).get("file_path", "")

if not file_path.startswith(ALLOWED_PREFIX):
    print(f"Access denied: only files under {ALLOWED_PREFIX} are allowed.", file=sys.stderr)
    sys.exit(2)

sys.exit(0)
```

---

## Blocking Dangerous Commands

Block destructive terminal commands.

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "pre_run_command": [
      {
        "command": "python3 .windsurf/hooks/block_dangerous.py",
        "show_output": true
      }
    ]
  }
}
```

`block_dangerous.py`:
```python
#!/usr/bin/env python3
import sys, json

BLOCKED_PATTERNS = [
    "rm -rf /",
    "git push --force",
    "git push -f",
    "git reset --hard",
    "mkfs",
    "> /dev/",
]

data = json.loads(sys.stdin.read())
cmd = data.get("tool_info", {}).get("command_line", "")

for pattern in BLOCKED_PATTERNS:
    if pattern in cmd:
        print(f"Blocked: command contains '{pattern}'", file=sys.stderr)
        sys.exit(2)

sys.exit(0)
```

---

## Auto-Formatting After Edits

Run prettier after every file modification.

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "post_write_code": [
      {
        "command": "python3 .windsurf/hooks/format_on_save.py",
        "show_output": false
      }
    ]
  }
}
```

`format_on_save.py`:
```python
#!/usr/bin/env python3
import sys, json, subprocess

data = json.loads(sys.stdin.read())
file_path = data.get("tool_info", {}).get("file_path", "")

if file_path.endswith((".js", ".jsx", ".ts", ".tsx", ".json", ".css", ".md")):
    subprocess.run(["prettier", "--write", file_path], capture_output=True)
elif file_path.endswith(".py"):
    subprocess.run(["black", file_path], capture_output=True)

sys.exit(0)
```

---

## Blocking Policy-Violating Prompts

Block user prompts that contain forbidden keywords.

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "pre_user_prompt": [
      {
        "command": "python3 .windsurf/hooks/validate_prompt.py",
        "show_output": true
      }
    ]
  }
}
```

`validate_prompt.py`:
```python
#!/usr/bin/env python3
import sys, json

FORBIDDEN = ["delete production", "drop database", "truncate table"]

data = json.loads(sys.stdin.read())
prompt = data.get("tool_info", {}).get("user_prompt", "").lower()

for term in FORBIDDEN:
    if term in prompt:
        print(f"Blocked: prompt contains '{term}'", file=sys.stderr)
        sys.exit(2)

sys.exit(0)
```

---

## Logging Cascade Responses

Log all Cascade responses to a file for compliance.

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "post_cascade_response": [
      {
        "command": "python3 .windsurf/hooks/log_responses.py"
      }
    ]
  }
}
```

`log_responses.py`:
```python
#!/usr/bin/env python3
import sys, json
from datetime import datetime

data = json.loads(sys.stdin.read())
response = data.get("tool_info", {}).get("response", "")
timestamp = data.get("timestamp", datetime.now().isoformat())

with open("cascade-responses.log", "a") as f:
    f.write(f"\n--- {timestamp} ---\n{response}\n")
```

---

## Worktree Setup Hook

Run initialization after a worktree is created.

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "post_setup_worktree": [
      {
        "command": "bash .windsurf/hooks/init_worktree.sh",
        "show_output": true
      }
    ]
  }
}
```

`init_worktree.sh`:
```bash
#!/bin/bash
echo "Worktree ready. Installing dependencies..."
npm install --silent
echo "Done."
```

---

## Multiple Hooks for the Same Event

You can have multiple hooks for the same event — they run in order.

```json
{
  "hooks": {
    "pre_run_command": [
      {
        "command": "python3 .windsurf/hooks/log_commands.py",
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

If any hook exits with code `2`, subsequent hooks still run but the action is blocked.