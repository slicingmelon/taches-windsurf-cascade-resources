# Hook Scripting Guide

How to implement Windsurf Cascade hooks: choosing and writing hook scripts.

> **Note**: Windsurf has only one hook type — **command**. All hooks are shell commands. There is no "prompt hook" type. If you need intelligent/LLM-based decisions, implement them by calling an external API from within your script.

> **Windows note**: Replace `python3` with `python` in all script examples below.

## Decision Tree

```
Need to implement a hook?
│
├─ Simple check (pattern match, file path, exit code)?
│  └─ Use a shell one-liner in hooks.json
│
├─ Moderate logic (parse JSON input, conditions)?
│  └─ Write a Python script
│
├─ Complex logic (multiple checks, structured output)?
│  └─ Write a Python or Node.js script
│
└─ System integration (OS notifications, git, formatters)?
   └─ Use a shell script
```

---

## Shell one-liners

Best for: simple logging, notifications, calling existing CLI tools.

```json
{
  "hooks": {
    "post_write_code": [
      {
        "command": "prettier --write \"$(cat /dev/stdin | python3 -c \"import sys,json; print(json.load(sys.stdin)['tool_info']['file_path'])\" 2>/dev/null)\""
      }
    ]
  }
}
```

For anything beyond trivial, prefer a script file — inline commands with JSON parsing are fragile.

---

## Python scripts

Best for: JSON parsing, conditional logic, multi-step validation. Python is available on all platforms and handles stdin/stdout cleanly.

**Template:**
```python
#!/usr/bin/env python3
import sys, json

data = json.loads(sys.stdin.read())
event = data.get("agent_action_name", "")
tool_info = data.get("tool_info", {})

# Your logic here
# ...

# Exit 0 = allow, exit 2 = block (pre-hooks only)
sys.exit(0)
```

**Blocking example:**
```python
#!/usr/bin/env python3
import sys, json

data = json.loads(sys.stdin.read())
cmd = data.get("tool_info", {}).get("command_line", "")

if "rm -rf /" in cmd:
    print("Blocked: destructive command detected", file=sys.stderr)
    sys.exit(2)

sys.exit(0)
```

**Logging example:**
```python
#!/usr/bin/env python3
import sys, json
from datetime import datetime

data = json.loads(sys.stdin.read())
with open("cascade.log", "a") as f:
    f.write(f"{datetime.now().isoformat()} {data.get('agent_action_name')} {json.dumps(data.get('tool_info', {}))}\n")
```

---

## Shell scripts

Best for: OS integration (notifications, git, formatters), chaining CLI tools.

**Template:**
```bash
#!/bin/bash
input=$(cat)  # Read stdin JSON

# Parse with python3 (more reliable than jq on all platforms)
file_path=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_info',{}).get('file_path',''))")

# Your logic
if [[ "$file_path" == *.py ]]; then
    black "$file_path" 2>/dev/null || true
fi

exit 0  # exit 2 to block
```

**macOS notification:**
```bash
#!/bin/bash
osascript -e 'display notification "Cascade finished" with title "Windsurf"'
```

**Linux notification:**
```bash
#!/bin/bash
notify-send "Windsurf" "Cascade finished"
```

---

## Node.js scripts

Best for: projects already using Node, complex async operations.

```javascript
#!/usr/bin/env node
const chunks = [];
process.stdin.on('data', c => chunks.push(c));
process.stdin.on('end', () => {
  const data = JSON.parse(Buffer.concat(chunks).toString());
  const cmd = data?.tool_info?.command_line ?? '';

  if (cmd.includes('rm -rf /')) {
    process.stderr.write('Blocked: destructive command\n');
    process.exit(2);
  }

  process.exit(0);
});
```

---

## Comparison

| Approach | Best for | Portability | JSON parsing |
|----------|----------|-------------|--------------|
| **Shell one-liner** | Single CLI call | macOS/Linux only | Fragile |
| **Python script** | Logic, validation, logging | All platforms | Native |
| **Shell script** | OS tools, notifications | macOS/Linux | Via python3 |
| **Node.js script** | Node projects, async | All platforms | Native |

---

## Combining multiple hooks

You can run multiple scripts for the same event — they run in order:

```json
{
  "hooks": {
    "pre_run_command": [
      { "command": "python3 .windsurf/hooks/log.py", "show_output": false },
      { "command": "python3 .windsurf/hooks/block_dangerous.py", "show_output": true }
    ]
  }
}
```

All hooks run even if one exits with `2`. The action is blocked if **any** hook exits `2`.
