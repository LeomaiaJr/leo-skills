---
name: leo-wiggum
description: Autonomous AI coding loop with PRD-based task tracking. Use when user says "leo-wiggum", "/leo-wiggum", "start leo loop", "autonomous coding", "run leo", or wants to implement a feature using iterative AI sessions that spawn fresh Claude Code instances. Takes a feature description, breaks it into user stories in a PRD, and runs an external loop where each iteration picks the next incomplete story.
---

# Leo Wiggum - Autonomous AI Coding Loop

External Ralph-style loop that spawns fresh Claude Code sessions to implement features iteratively.

## How It Works

1. Generate a PRD (`prd.json`) with user stories from your feature description
2. Create `progress.txt` for learnings across iterations
3. Run external bash loop that spawns fresh Claude Code sessions
4. Each session: picks next story → implements → tests → commits → marks done
5. Memory persists via git commits, `prd.json`, and `progress.txt`

## Usage

Parse from user input:
- **prompt** (required): Feature description
- **--max-iterations N**: Max iterations (default: 10)
- **--branch name**: Git branch (default: `leo/<feature-slug>`)

## Step 1: Analyze Codebase

Before generating PRD:
1. Read `CLAUDE.md` if exists
2. Explore relevant code with Glob/Grep
3. Understand tech stack and patterns

## Step 2: Generate User Stories

Break feature into small stories completable in ONE iteration.

**Right-sized:**
- Add database column + migration
- Add single UI component
- Update one API endpoint
- Add filter/dropdown
- Write tests for one module

**Too big (split):**
- "Build entire dashboard"
- "Add authentication"
- "Refactor API"

## Step 3: Create prd.json

```json
{
  "project": "<project name>",
  "branchName": "leo/<feature-slug>",
  "description": "<feature description>",
  "userStories": [
    {
      "id": "US-001",
      "title": "<title>",
      "description": "As a <user>, I want <goal>, so that <benefit>",
      "acceptanceCriteria": [
        "<criterion 1>",
        "<criterion 2>",
        "Typecheck passes",
        "Tests pass"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

Priority 1 = highest. For UI stories, add: "Verify in browser"

## Step 4: Create progress.txt

```
# Leo Wiggum Progress Log
Feature: <name>
Branch: <branch>
Started: <datetime>

## Codebase Patterns
(Patterns added as discovered)

---
```

## Step 5: Show Summary

Display:
- Number of stories
- Story titles with priorities
- Branch name
- Command to run

## Step 6: Start Loop

Ask user to confirm, then run:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/leo-wiggum.sh <max_iterations>
```

**CRITICAL:** After starting, END response. The script spawns NEW sessions.

## Monitoring

- Terminal: iteration progress
- `progress.txt`: learnings
- `git log`: commits
- `prd.json`: story status
