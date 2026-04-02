---
name: create-hooks
description: Expert guidance for creating, configuring, and using Windsurf Cascade hooks. Use when working with hooks, setting up event listeners, validating commands, automating workflows, adding notifications, or understanding hook types (pre_run_command, post_write_code, pre_user_prompt, post_cascade_response, etc).
---

<objective>
Hooks are event-driven automation for Windsurf Cascade that execute shell commands in response to file reads, code writes, terminal commands, MCP tool use, and user prompts. This skill teaches you how to create, configure, and debug hooks for validating commands, automating workflows, restricting access, and logging Cascade actions.

Hooks provide programmatic control over Cascade's behavior without modifying core code, enabling project-specific automation, safety checks, and workflow customization.
</objective>

<context>
Hooks are shell commands that execute in response to Cascade events. Each hook receives a JSON object via stdin describing the action, executes your script, and communicates results via exit code and stdout. Pre-hooks can block actions by exiting with code `2`. Post-hooks observe and log but cannot block.

Hooks are loaded and merged from three levels: system → user → workspace.
</context>

<quick_start>
<workflow>
1. Create hooks config file:
   - Workspace: `.windsurf/hooks.json` (version-controlled, project-specific)
   - User: `~/.codeium/windsurf/hooks.json` (personal preferences)
   - System: `C:\ProgramData\Windsurf\hooks.json` (Windows) / `/Library/Application Support/Windsurf/hooks.json` (macOS)
2. Choose hook event (when it fires)
3. Write a shell script or inline command
4. Test by triggering the relevant Cascade action
</workflow>

<example>
**Log all terminal commands**:

`.windsurf/hooks.json`:
```json
{
  "hooks": {
    "pre_run_command": [
      {
        "command": "python3 .windsurf/hooks/log_commands.py",
        "show_output": true
      }
    ]
  }
}
```

`log_commands.py`:
```python
import sys, json
data = json.loads(sys.stdin.read())
cmd = data.get("tool_info", {}).get("command_line", "")
with open("cascade-commands.log", "a") as f:
    f.write(cmd + "\n")
```

This hook:
- Fires before (`pre_run_command`) every terminal command
- Logs the command to a file
- Does NOT block (exits with 0)
</example>
</quick_start>

<hook_events>
| Event | When it fires | Can block? |
|-------|---------------|------------|
| **pre_read_code** | Before Cascade reads a file | Yes |
| **post_read_code** | After Cascade reads a file | No |
| **pre_write_code** | Before Cascade writes/modifies a file | Yes |
| **post_write_code** | After Cascade writes/modifies a file | No |
| **pre_run_command** | Before Cascade runs a terminal command | Yes |
| **post_run_command** | After Cascade runs a terminal command | No |
| **pre_mcp_tool_use** | Before Cascade calls an MCP tool | Yes |
| **post_mcp_tool_use** | After Cascade calls an MCP tool | No |
| **pre_user_prompt** | Before Cascade processes a user prompt | Yes |
| **post_cascade_response** | After Cascade completes a response (async) | No |
| **post_cascade_response_with_transcript** | After response, includes full transcript | No |
| **post_setup_worktree** | After a worktree is set up | No |

**Blocking**: Pre-hooks exit with code `2` to block. Post-hooks cannot block (action already occurred).
</hook_events>

<hook_anatomy>
Each hook entry accepts:

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Shell command to execute. Can be any executable with arguments. |
| `show_output` | boolean | Whether to display hook stdout/stderr in Cascade UI. Useful for debugging. |
| `working_directory` | string | Optional. Directory to run command from. Defaults to workspace root. |

```json
{
  "hooks": {
    "post_write_code": [
      {
        "command": "python3 .windsurf/hooks/format.py",
        "show_output": false,
        "working_directory": "/absolute/path/to/project"
      }
    ]
  }
}
```

**Note**: There is no `type: "prompt"` in Windsurf hooks. All hooks are shell commands. Complex validation logic must be implemented in your script.
</hook_anatomy>

<input_schemas>
All hooks receive a JSON object via stdin with these common fields:

```json
{
  "agent_action_name": "pre_run_command",
  "trajectory_id": "...",
  "execution_id": "...",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": { ... }
}
```

**Event-specific `tool_info`**:

`pre_read_code` / `post_read_code`:
```json
{ "file_path": "/path/to/file.py" }
```

`pre_write_code` / `post_write_code`:
```json
{
  "file_path": "/path/to/file.py",
  "edits": [{ "old_string": "...", "new_string": "..." }]
}
```

`pre_run_command` / `post_run_command`:
```json
{
  "command_line": "npm install package-name",
  "cwd": "/path/to/project"
}
```

`pre_mcp_tool_use` / `post_mcp_tool_use`:
```json
{
  "mcp_server_name": "github",
  "mcp_tool_name": "create_issue",
  "mcp_tool_arguments": { ... }
}
```

`pre_user_prompt`:
```json
{ "user_prompt": "can you run the echo hello command" }
```

`post_cascade_response`:
```json
{ "response": "### Planner Response\n\n..." }
```
</input_schemas>

<blocking>
Pre-hooks block actions by **exiting with code `2`**. Any output to stderr is shown to Cascade as the reason.

```python
import sys, json

data = json.loads(sys.stdin.read())
cmd = data.get("tool_info", {}).get("command_line", "")

if "git push --force" in cmd:
    print("Blocked: force push is not allowed.", file=sys.stderr)
    sys.exit(2)  # Blocks the action

sys.exit(0)  # Allows the action
```

**Exit codes**:
- `0` → Success, action proceeds
- `2` → Block (pre-hooks only) — Cascade sees stderr message
- Any other → Error, action proceeds normally
</blocking>

<common_patterns>
**Block dangerous commands**:
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

**Auto-format code after edits**:
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

**Restrict file access**:
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

**Log all Cascade responses**:
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

**Block policy-violating prompts**:
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
</common_patterns>

<debugging>
Test hooks by triggering the relevant Cascade action (read a file, run a command, etc.) and observe the output. Set `"show_output": true` during development to see hook stdout/stderr in the Cascade UI.

Validate your JSON config before use:
```bash
python3 -m json.tool .windsurf/hooks.json
```

See [references/troubleshooting.md](references/troubleshooting.md) for common issues and solutions.
</debugging>

<reference_guides>
**Hook types and events**: [references/hook-types.md](references/hook-types.md)
- Complete list of hook events
- When each event fires
- Input schemas for each event
- Blocking vs non-blocking hooks

**Input/Output schemas**: [references/input-output-schemas.md](references/input-output-schemas.md)
- Complete schema for each hook type
- Field descriptions and types
- Example JSON for each event

**Working examples**: [references/examples.md](references/examples.md)
- Logging all Cascade actions
- Restricting file access
- Blocking dangerous commands
- Auto-formatting after edits
- Validating user prompts

**Troubleshooting**: [references/troubleshooting.md](references/troubleshooting.md)
- Hooks not triggering
- Script execution failures
- Permission problems
- Debug workflow
</reference_guides>

<security_checklist>
**Critical safety requirements**:

- **Permission validation**: Ensure hook scripts have executable permissions (`chmod +x`) on macOS/Linux
- **Path safety**: Use absolute paths or paths relative to workspace root
- **JSON validation**: Validate hook config with `python3 -m json.tool` before use
- **Selective blocking**: Be conservative with pre-hooks to avoid disrupting workflow
- **Script errors**: Non-zero exit codes other than `2` let actions proceed — handle exceptions in scripts
- **`show_output` during dev**: Set `true` while developing, `false` for production to keep UI clean

**Testing protocol**:
```bash
# Validate JSON config
python3 -m json.tool .windsurf/hooks.json

# Test script manually
echo '{"agent_action_name":"pre_run_command","tool_info":{"command_line":"echo test","cwd":"/tmp"},"trajectory_id":"test","execution_id":"test","timestamp":"2025-01-01T00:00:00Z"}' | python3 .windsurf/hooks/your_script.py
```
</security_checklist>

<success_criteria>
A working hook configuration has:

- Valid JSON in `.windsurf/hooks.json` (validated with `python3 -m json.tool`)
- Appropriate hook event selected for the use case
- Script reads JSON from stdin correctly
- Pre-hooks exit `2` to block, `0` to allow
- `show_output: true` set during development for visibility
- Tested by triggering the actual Cascade action
- Executable permissions set on script files (macOS/Linux)
</success_criteria>
