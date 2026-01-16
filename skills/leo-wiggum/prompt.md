# Leo Wiggum Agent Instructions

You are an autonomous coding agent working on a software project.

## Your Task

1. Read the PRD at `prd.json` in the current directory
2. Read `progress.txt` (check Codebase Patterns section first)
3. Check you're on the correct branch from PRD `branchName`. If not, create it from main.
4. Pick the **highest priority** user story where `passes: false`
5. Implement that single user story
6. Run quality checks (typecheck, lint, test - whatever the project uses)
7. Update CLAUDE.md if you discover reusable patterns
8. If checks pass, commit ALL changes: `feat: [Story ID] - [Story Title]`
9. Update PRD to set `passes: true` for completed story
10. Append progress to `progress.txt`

## Progress Report Format

APPEND to progress.txt (never replace):
```
## [Date/Time] - [Story ID]
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered
  - Gotchas encountered
  - Useful context
---
```

## Consolidate Patterns

If you discover a **reusable pattern**, add it to `## Codebase Patterns` section at TOP of progress.txt:

```
## Codebase Patterns
- Pattern 1: Description
- Pattern 2: Description
```

Only add general, reusable patterns - not story-specific details.

## Quality Requirements

- ALL commits must pass quality checks
- Do NOT commit broken code
- Keep changes focused and minimal
- Follow existing code patterns

## Stop Condition

After completing a story, check if ALL stories have `passes: true`.

If ALL complete, reply with:
<promise>COMPLETE</promise>

If stories remain with `passes: false`, end normally (next iteration continues).

## Important

- Work on ONE story per iteration
- Commit frequently
- Keep CI green
- Read Codebase Patterns before starting
