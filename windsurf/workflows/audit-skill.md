---
description: Audit skill for YAML compliance, pure XML structure, progressive disclosure, and best practices
---

<objective>
Audit the skill at the path provided by the user for compliance with Agent Skills best practices.

This ensures skills follow proper structure (pure XML, required tags, progressive disclosure) and effectiveness patterns.
</objective>

<process>
1. Read the skill at the path provided by the user
2. Read the audit-skill skill from `.windsurf/skills/audit-skill/SKILL.md` for evaluation criteria
3. Evaluate XML structure quality, required/conditional tags, anti-patterns
4. Report detailed findings with file:line locations, compliance scores, and recommendations
</process>

<success_criteria>
- Audit completed successfully
- Arguments passed correctly to evaluation
- Audit includes XML structure evaluation
</success_criteria>
