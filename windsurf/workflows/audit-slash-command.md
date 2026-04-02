---
description: Audit slash command file for YAML, arguments, dynamic context, tool restrictions, and content quality
---

<objective>
Audit the slash command at the path provided by the user for compliance with best practices.

This ensures commands follow security, clarity, and effectiveness standards.
</objective>

<process>
1. Read the command file at the path provided by the user
2. Read the audit-slash-command skill from `.windsurf/skills/audit-slash-command/SKILL.md` for evaluation criteria
3. Evaluate the command against security, clarity, and effectiveness standards
4. Report detailed findings with file:line locations, compliance scores, and recommendations
</process>

<success_criteria>
- Evaluation completed successfully
- Findings reported correctly
</success_criteria>
