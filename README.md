# TÂCHES Windsurf Cascade Resources

A Windsurf-compatible port of the [TÂCHES Claude Code Resources](https://github.com/glittercowboy/taches-cc-resources) — the same workflows and skills, adapted for Windsurf Cascade.

## Philosophy

When you use a tool like Windsurf Cascade, it's your responsibility to assume everything is possible.

I built these tools using that mindset.

Dream big. Happy building.

— TÂCHES

## What's Inside

**[Workflows](#workflows)** (39 total) - Slash workflows that expand into structured Cascade sessions
- **Meta-Prompting**: Separate planning from execution with staged prompts
- **Todo Management**: Capture context mid-work, resume later with full state
- **Thinking Models**: Mental frameworks (first principles, inversion, 80/20, etc.)
- **Research**: Deep dives, competitive analysis, feasibility, landscape mapping
- **Deep Analysis**: Systematic debugging methodology with evidence and hypothesis testing

**[Skills](#skills)** (10 total) - Autonomous workflows that research, generate, and self-heal
- **Create Plans**: Hierarchical project planning for solo developer + Cascade workflows
- **Create MCP Servers**: Build MCP servers for Windsurf integrations (Python/TypeScript)
- **Create Agent Skills**: Build new skills by describing what you want
- **Create Meta-Prompts**: Generate staged workflow prompts with dependency detection
- **Create Slash Commands**: Build custom commands with proper structure
- **Create Subagents**: Build specialized agent instances for isolated contexts
- **Create Hooks**: Build event-driven automation
- **Debug Like Expert**: Systematic debugging with evidence gathering and hypothesis testing
- **Setup Ralph**: Set up Geoffrey Huntley's Ralph Wiggum autonomous coding loop

## Installation

### Option 1: Clone and use directly (easiest)

The `.windsurf/` folder ships with this repo. Clone it, open in Windsurf, and all workflows and skills are immediately available — no copying needed.

```bash
git clone https://github.com/slicingmelon/taches-windsurf-cascade-resources.git
```

Open the cloned folder in Windsurf. Done.

---

### Option 2: Global install (use in every project)

Installs workflows, skills, and rules globally so they are available in **every project** on your machine. This is the Windsurf equivalent of Claude CC's `~/.claude/commands/` global install.

#### PowerShell (Windows)

```powershell
# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codeium\windsurf\global_workflows"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codeium\windsurf\skills"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codeium\windsurf\global_rules"

# Install
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf\workflows\*" -Destination "$env:USERPROFILE\.codeium\windsurf\global_workflows\" -Recurse -Force
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf\skills\*" -Destination "$env:USERPROFILE\.codeium\windsurf\skills\" -Recurse -Force
Copy-Item -Path ".\taches-windsurf-cascade-resources\.windsurf\rules\*" -Destination "$env:USERPROFILE\.codeium\windsurf\global_rules\" -Recurse -Force
```

#### Bash (macOS/Linux)

```bash
mkdir -p ~/.codeium/windsurf/global_workflows
mkdir -p ~/.codeium/windsurf/skills
mkdir -p ~/.codeium/windsurf/global_rules

cp -R ./taches-windsurf-cascade-resources/.windsurf/workflows/* ~/.codeium/windsurf/global_workflows/
cp -R ./taches-windsurf-cascade-resources/.windsurf/skills/* ~/.codeium/windsurf/skills/
cp -R ./taches-windsurf-cascade-resources/.windsurf/rules/* ~/.codeium/windsurf/global_rules/
```

Restart Windsurf after copying for discovery.

### Option 3: Project-local install

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

Workflows install to `.windsurf/workflows/`. Skills install to `.windsurf/skills/`. Project-specific data (prompts, todos) lives in each project's working directory.

## Workflows

### Meta-Prompting

Separate analysis from execution. Describe what you want in natural language, Cascade generates a rigorous prompt, then runs it in a fresh context.

- [`/create-prompt`](./.windsurf/workflows/create-prompt.md) - Generate optimized prompts with XML structure
- [`/run-prompt`](./.windsurf/workflows/run-prompt.md) - Execute saved prompts in delegated sub-task contexts

### Todo Management

Capture ideas mid-conversation without derailing current work. Resume later with full context intact.

- [`/add-to-todos`](./.windsurf/workflows/add-to-todos.md) - Capture tasks with full context
- [`/check-todos`](./.windsurf/workflows/check-todos.md) - Resume work on captured tasks

### Context Handoff

Create structured handoff documents to continue work in a fresh context. Reference with `@whats-next.md` to resume seamlessly.

- [`/whats-next`](./.windsurf/workflows/whats-next.md) - Create handoff document for fresh context

### Create Extensions

Workflows that invoke the skills below.

- [`/create-agent-skill`](./.windsurf/workflows/create-agent-skill.md) - Create a new skill
- [`/create-meta-prompt`](./.windsurf/workflows/create-meta-prompt.md) - Create staged workflow prompts
- [`/create-slash-command`](./.windsurf/workflows/create-slash-command.md) - Create a new slash command
- [`/create-subagent`](./.windsurf/workflows/create-subagent.md) - Create a new subagent
- [`/create-hook`](./.windsurf/workflows/create-hook.md) - Create a new hook
- [`/create-plan`](./.windsurf/workflows/create-plan.md) - Create a hierarchical project plan

### Audit Extensions

Invoke auditor skill methodology.

- [`/audit-skill`](./.windsurf/workflows/audit-skill.md) - Audit skill for best practices
- [`/audit-slash-command`](./.windsurf/workflows/audit-slash-command.md) - Audit command for best practices
- [`/audit-subagent`](./.windsurf/workflows/audit-subagent.md) - Audit subagent for best practices

### Self-Improvement

- [`/heal-skill`](./.windsurf/workflows/heal-skill.md) - Fix skills based on execution issues

### Thinking Models

Apply mental frameworks to decisions and problems.

- [`/pareto`](./.windsurf/workflows/consider/pareto.md) - Apply 80/20 rule to focus on what matters
- [`/first-principles`](./.windsurf/workflows/consider/first-principles.md) - Break down to fundamentals and rebuild
- [`/inversion`](./.windsurf/workflows/consider/inversion.md) - Solve backwards (what guarantees failure?)
- [`/second-order`](./.windsurf/workflows/consider/second-order.md) - Think through consequences of consequences
- [`/5-whys`](./.windsurf/workflows/consider/5-whys.md) - Drill to root cause
- [`/occams-razor`](./.windsurf/workflows/consider/occams-razor.md) - Find simplest explanation
- [`/one-thing`](./.windsurf/workflows/consider/one-thing.md) - Identify highest-leverage action
- [`/swot`](./.windsurf/workflows/consider/swot.md) - Map strengths, weaknesses, opportunities, threats
- [`/eisenhower-matrix`](./.windsurf/workflows/consider/eisenhower-matrix.md) - Prioritize by urgent/important
- [`/10-10-10`](./.windsurf/workflows/consider/10-10-10.md) - Evaluate across time horizons
- [`/opportunity-cost`](./.windsurf/workflows/consider/opportunity-cost.md) - Analyze what you give up
- [`/via-negativa`](./.windsurf/workflows/consider/via-negativa.md) - Improve by removing

### Research

Systematic research with structured output saved to `artifacts/research/`.

- [`/competitive`](./.windsurf/workflows/research/competitive.md) - Research competitors: who else does this, how, strengths/weaknesses
- [`/deep-dive`](./.windsurf/workflows/research/deep-dive.md) - Comprehensive investigation of a topic with sources
- [`/feasibility`](./.windsurf/workflows/research/feasibility.md) - Reality check: can we actually do this with our constraints?
- [`/history`](./.windsurf/workflows/research/history.md) - Research what's been tried before, lessons learned
- [`/landscape`](./.windsurf/workflows/research/landscape.md) - Map the space: tools, players, trends, gaps
- [`/open-source`](./.windsurf/workflows/research/open-source.md) - Find open-source libraries and tools that solve this
- [`/options`](./.windsurf/workflows/research/options.md) - Compare multiple options side-by-side with recommendation
- [`/technical`](./.windsurf/workflows/research/technical.md) - Research how to implement something: approaches, libraries, tradeoffs

### Deep Analysis

Systematic debugging with methodical investigation.

- [`/debug`](./.windsurf/workflows/debug.md) - Apply expert debugging methodology to investigate issues

---

## Skills

### [Create Plans](./.windsurf/skills/create-plans/)

Hierarchical project planning optimized for solo developer + Cascade. Create executable plans that Cascade runs, not enterprise documentation that sits unused.

**PLAN.md IS the prompt** - not documentation that gets transformed later. Brief → Roadmap → Research (if needed) → PLAN.md → Execute → SUMMARY.md.

**Commands:** `/create-plan` (invoke skill), `/run-plan` (execute PLAN.md with intelligent segmentation)

### [Create Agent Skills](./.windsurf/skills/create-agent-skills/)

Build skills by describing what you want. Asks clarifying questions, researches APIs if needed, and generates properly structured skill files.

When things don't work perfectly, `/heal-skill` analyzes what went wrong and updates the skill based on what actually worked.

Commands: `/create-agent-skill`, `/heal-skill`, `/audit-skill`

### [Create Meta-Prompts](./.windsurf/skills/create-meta-prompts/)

Builds prompts with structured outputs (research.md, plan.md) that subsequent prompts can parse. Adds automatic dependency detection to chain research → plan → implement workflows.

Commands: `/create-meta-prompt`

### [Create Slash Commands](./.windsurf/skills/create-slash-commands/)

Build commands that expand into full prompts when invoked. Describe the command you want, get proper configuration with arguments and dynamic context loading.

Commands: `/create-slash-command`, `/audit-slash-command`

### [Create Subagents](./.windsurf/skills/create-subagents/)

Build specialized agent instances that run in isolated contexts. Describe the agent's purpose, get optimized system prompts with the right tool access and orchestration patterns.

Commands: `/create-subagent`, `/audit-subagent`

### [Create Hooks](./.windsurf/skills/create-hooks/)

Build event-driven automation that triggers on tool calls, session events, or prompt submissions. Describe what you want to automate, get working Cascade hook configurations.

Commands: `/create-hook`

### [Create MCP Servers](./.windsurf/skills/create-mcp-servers/)

Build Model Context Protocol (MCP) servers that expose tools, resources, and prompts to Cascade. Supports Python and TypeScript implementations.

### [Debug Like Expert](./.windsurf/skills/debug-like-expert/)

Deep analysis debugging mode for complex issues. Activates methodical investigation protocol with evidence gathering, hypothesis testing, and rigorous verification.

Commands: `/debug`

### [Setup Ralph](./.windsurf/skills/setup-ralph/)

Set up Geoffrey Huntley's Ralph Wiggum autonomous coding loop. Ralph is an autonomous AI coding methodology that uses iterative loops with task selection, execution, and validation.

**Three phases:** Planning (gap analysis → TODO list), Building (implement one task, validate, commit), Observation (you engineer the environment).

Commands: `/setup-ralph`

### [The Pirate Bay](./.windsurf/skills/the-pirate-bay/)

Search The Pirate Bay for torrents and extract magnet links via the apibay.org JSON API. Supports searching by keyword, browsing top torrents by category, and filtering by seeders.

Commands: invoked automatically when asked to search for torrents or find magnet links

---

## Recommended Workflow

**For building projects:** Use `/create-plan` to invoke the Create Plans skill. After planning, use `/run-plan` to execute phases with intelligent segmentation.

**For research:** Use the `/research/*` workflows. Each saves structured output to `artifacts/research/` in your working directory.

**For decisions:** Use the thinking model workflows (`/pareto`, `/first-principles`, `/inversion`, etc.) to apply mental frameworks to any problem or discussion.

**Other tools:** `/create-prompt` + `/run-prompt` for custom Cascade-to-Cascade pipelines.

---

More resources coming soon.

---

**Original Claude Code version:** [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources)

—TÂCHES
