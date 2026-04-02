# Hook Types and Events

Complete reference for all Windsurf Cascade hook events.

Windsurf provides 12 hook events covering the full agent workflow. All hooks are shell commands — there is no `type: "prompt"` LLM hook type in Windsurf.

---

## Common Input Structure

All hooks receive JSON via stdin with these common fields:

```json
{
  "agent_action_name": "pre_run_command",
  "trajectory_id": "abc-123",
  "execution_id": "xyz-456",
  "timestamp": "2025-01-15T10:30:00Z",
  "tool_info": { ... }
}
```

---

## pre_read_code

**When it fires**: Before Cascade reads a file or directory

**Can block**: Yes (exit code 2)

**tool_info**:
```json
{ "file_path": "/path/to/file.py" }
```

**Use cases**: Restrict file access, log reads, enforce read permissions

---

## post_read_code

**When it fires**: After Cascade successfully reads a file

**Can block**: No

**tool_info**:
```json
{ "file_path": "/path/to/file.py" }
```

**Use cases**: Log successful reads, track file access patterns

---

## pre_write_code

**When it fires**: Before Cascade writes or modifies a file

**Can block**: Yes (exit code 2)

**tool_info**:
```json
{
  "file_path": "/path/to/file.py",
  "edits": [
    { "old_string": "def old():\n    pass", "new_string": "def new():\n    return True" }
  ]
}
```

**Use cases**: Prevent writes to protected files, backup before changes, enforce naming conventions

---

## post_write_code

**When it fires**: After Cascade writes or modifies a file

**Can block**: No

**tool_info**:
```json
{
  "file_path": "/path/to/file.py",
  "edits": [
    { "old_string": "import os", "new_string": "import os\nimport sys" }
  ]
}
```

**Use cases**: Run linters/formatters, run tests after changes, log modifications

---

## pre_run_command

**When it fires**: Before Cascade runs a terminal command

**Can block**: Yes (exit code 2)

**tool_info**:
```json
{
  "command_line": "npm install package-name",
  "cwd": "/path/to/project"
}
```

**Use cases**: Block dangerous commands, log all command executions, enforce allowed command lists

---

## post_run_command

**When it fires**: After Cascade runs a terminal command

**Can block**: No

**tool_info**:
```json
{
  "command_line": "npm install package-name",
  "cwd": "/path/to/project"
}
```

**Use cases**: Log command results, trigger follow-up actions

---

## pre_mcp_tool_use

**When it fires**: Before Cascade calls an MCP tool

**Can block**: Yes (exit code 2)

**tool_info**:
```json
{
  "mcp_server_name": "github",
  "mcp_tool_name": "create_issue",
  "mcp_tool_arguments": {
    "owner": "my-org",
    "repo": "my-repo",
    "title": "Bug report",
    "body": "Description"
  }
}
```

**Use cases**: Log MCP usage, restrict which MCP tools can be used, audit external API calls

---

## post_mcp_tool_use

**When it fires**: After Cascade successfully calls an MCP tool

**Can block**: No

**tool_info**:
```json
{
  "mcp_server_name": "github",
  "mcp_tool_name": "list_commits",
  "mcp_tool_arguments": { ... },
  "mcp_result": "..."
}
```

**Use cases**: Log MCP operations, track API usage, see MCP results

---

## pre_user_prompt

**When it fires**: Before Cascade processes a user prompt

**Can block**: Yes (exit code 2)

**Note**: `show_output` does not apply to this hook.

**tool_info**:
```json
{ "user_prompt": "can you run the echo hello command" }
```

**Use cases**: Log all user prompts for auditing, block policy-violating prompts

---

## post_cascade_response

**When it fires**: Asynchronously after Cascade completes a response

**Can block**: No

**Note**: `show_output` does not apply to this hook. Triggered async — does not delay Cascade.

**tool_info**:
```json
{
  "response": "### Planner Response\n\nI'll help you create that file.\n\n..."
}
```

**Use cases**: Log responses for auditing, analyze response patterns, send to external systems

---

## post_cascade_response_with_transcript

**When it fires**: After response, includes full conversation transcript as JSONL file path

**Can block**: No

**tool_info**:
```json
{ "transcript_path": "/path/to/transcript.jsonl" }
```

**Use cases**: Compliance logging, full audit trails with context

---

## post_setup_worktree

**When it fires**: After a git worktree is set up

**Can block**: No

**Use cases**: Initialize worktree-specific environments, run setup scripts

---

## Blocking Rules

Only pre-hooks can block:
- `pre_read_code`
- `pre_write_code`
- `pre_run_command`
- `pre_mcp_tool_use`
- `pre_user_prompt`

**Exit codes**:
- `0` → Success, action proceeds
- `2` → Block — Cascade sees stderr as the reason
- Any other → Error, action proceeds normally
