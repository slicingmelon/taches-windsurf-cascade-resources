# Input/Output Schemas

Complete JSON schemas for all Windsurf Cascade hook types.

## Common Input Fields

All hooks receive JSON via stdin with these fields:

```json
{
  "agent_action_name": "pre_run_command",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": { ... }
}
```

- `agent_action_name`: The hook event name (e.g., `pre_run_command`, `post_write_code`)
- `trajectory_id`: Unique ID for the overall Cascade conversation
- `execution_id`: Unique ID for the single agent turn
- `timestamp`: ISO 8601 timestamp when the hook fired
- `tool_info`: Event-specific data (see per-event schemas below)

---

## pre_read_code

**Full input**:
```json
{
  "agent_action_name": "pre_read_code",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": {
    "file_path": "/path/to/file.py"
  }
}
```

**Can block**: Yes (exit code 2)

**Blocking**: Write to stderr and exit 2.

---

## post_read_code

**tool_info**:
```json
{ "file_path": "/path/to/file.py" }
```

**Can block**: No

---

## pre_write_code

**Full input**:
```json
{
  "agent_action_name": "pre_write_code",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": {
    "file_path": "/path/to/file.py",
    "edits": [
      {
        "old_string": "def old_function():\n    pass",
        "new_string": "def new_function():\n    return True"
      }
    ]
  }
}
```

**Can block**: Yes (exit code 2)

**Access in Python**:
```python
import sys, json
data = json.loads(sys.stdin.read())
file_path = data["tool_info"]["file_path"]
edits = data["tool_info"].get("edits", [])
```

---

## post_write_code

**tool_info**:
```json
{
  "file_path": "/path/to/file.py",
  "edits": [
    { "old_string": "import os", "new_string": "import os\nimport sys" }
  ]
}
```

**Can block**: No

---

## pre_run_command

**Full input**:
```json
{
  "agent_action_name": "pre_run_command",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": {
    "command_line": "npm install package-name",
    "cwd": "/path/to/project"
  }
}
```

**Can block**: Yes (exit code 2)

**Access in Python**:
```python
cmd = data["tool_info"]["command_line"]
cwd = data["tool_info"]["cwd"]
```

---

## post_run_command

**tool_info**:
```json
{
  "command_line": "npm install package-name",
  "cwd": "/path/to/project"
}
```

**Can block**: No

---

## pre_mcp_tool_use

**Full input**:
```json
{
  "agent_action_name": "pre_mcp_tool_use",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": {
    "mcp_server_name": "github",
    "mcp_tool_name": "create_issue",
    "mcp_tool_arguments": {
      "owner": "my-org",
      "repo": "my-repo",
      "title": "Bug report",
      "body": "Description"
    }
  }
}
```

**Can block**: Yes (exit code 2)

---

## post_mcp_tool_use

**tool_info**:
```json
{
  "mcp_server_name": "github",
  "mcp_tool_name": "list_commits",
  "mcp_tool_arguments": { ... },
  "mcp_result": "..."
}
```

**Can block**: No

---

## pre_user_prompt

**Full input**:
```json
{
  "agent_action_name": "pre_user_prompt",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": {
    "user_prompt": "can you run the echo hello command"
  }
}
```

**Can block**: Yes (exit code 2)

**Note**: `show_output` config option does not apply to this hook.

---

## post_cascade_response

**Full input**:
```json
{
  "agent_action_name": "post_cascade_response",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": {
    "response": "### Planner Response\n\nI'll help you create that file.\n\n*Created file `/path/to/file.py`*\n\nThe file has been created successfully."
  }
}
```

**Can block**: No. Triggered async after response completes.

**Note**: `show_output` config option does not apply to this hook.

---

## post_cascade_response_with_transcript

**tool_info**:
```json
{ "transcript_path": "/path/to/transcript.jsonl" }
```

**Can block**: No. Reads full conversation history from JSONL file.

---

## post_setup_worktree

**Can block**: No. Fires after a git worktree is set up.

---

## Output / Blocking

Windsurf hooks communicate via **exit codes only**:

| Exit Code | Meaning |
|-----------|---------|
| `0` | Success — action proceeds normally |
| `2` | Block — for pre-hooks, this prevents the action. Cascade sees stderr as the reason. |
| Any other | Error — action proceeds normally |

**To block** (pre-hooks only):
```python
import sys
print("Reason the action was blocked.", file=sys.stderr)
sys.exit(2)
```

**To allow**:
```python
sys.exit(0)
```

There is no JSON output schema for Windsurf hooks. Hooks do not return JSON decisions — they communicate exclusively through exit codes and stderr (for block reasons).
