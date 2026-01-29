---
name: leo-wiggum
description: >
  Autonomous AI coding loop v2 with phased execution, dependency graphs,
  browser validation, structured memory, and quality ratcheting.
  Use when user says "leo-wiggum", "/leo-wiggum", "start leo loop",
  "autonomous coding", "run leo", or wants to implement features or build
  entire projects using iterative AI sessions. Works on any codebase or
  greenfield projects.
allowed-tools: Bash(agent-browser:*)
---

# Leo Wiggum v2 - Autonomous AI Coding Loop

Phased, skill-aware autonomous coding loop with browser validation, structured memory, and quality ratcheting. Works on any project or from scratch.

## How It Works

1. **Phase 0 — Discovery/Scaffold**: Analyze codebase or scaffold a new project
2. **Phase 1 — Foundation**: Core infrastructure stories (schema, auth, config)
3. **Phase 2 — Features**: Story-based implementation with dependency ordering
4. **Phase 3 — Polish & Validation**: Integration validation, browser smoke tests, cleanup
5. Each iteration agent receives skill assignments and structured memory from previous iterations
6. Memory persists via `.leo/` directory (prd.json, memory.json, quality-metrics.json, screenshots)

## Usage

Parse from user input:
- **prompt** (required): Feature or project description
- **--max-iterations N**: Max iterations (default: 15)
- **--branch name**: Git branch (default: `leo/<feature-slug>`)
- **--greenfield**: Force greenfield scaffolding mode
- **--headed**: Run browser validation in headed mode (visible)

## Step 1: Discovery / Scaffold

### Existing Project
1. Read `CLAUDE.md` if exists
2. Detect tech stack by checking: `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `requirements.txt`, `Makefile`, etc.
3. Explore code structure with Glob/Grep to understand patterns
4. Identify and populate `techStack` in PRD:
   - `language`, `framework`
   - `buildCmd`, `testCmd`, `lintCmd`, `typecheckCmd`
   - `devServerCmd`, `devServerUrl`
5. Run baseline quality check (typecheck, tests, lint) and record in `quality-metrics.json`

### Greenfield (--greenfield flag or no recognizable project files)
1. Infer desired stack from the user's prompt (or ask if unclear)
2. Generate scaffold story as first Phase 1 story (`US-000: Initialize project scaffold`)
3. ALL other stories `dependsOn: ["US-000"]`
4. Set `techStack` with expected commands for the chosen framework
5. Quality baseline is captured AFTER the scaffold story passes

## Step 2: Generate Phased User Stories

Break the feature/project into stories organized by phase. Each story must be completable in ONE iteration.

### Skill Assignment

Assign 1-3 skills per story based on its content:

| Skill | When to Assign |
|-------|---------------|
| `code` | Always — general implementation |
| `database` | Schema changes, migrations, seed data |
| `api` | API endpoint creation or modification |
| `ui` | Frontend component work |
| `browser` | Story has visual output to validate |
| `test` | Test-focused or test-heavy stories |

### Right-Sized Stories
- Add database model + migration
- Add single UI component or page
- Create one API endpoint
- Add form with validation
- Write tests for one module

### Too Big (must split)
- "Build entire dashboard" -> split into individual pages/components
- "Add authentication" -> split into model, API, UI, tests
- "Refactor API" -> split by domain/router

### Dependency Graph
- Stories declare `dependsOn: ["US-XXX"]` for explicit ordering
- The iteration loop only picks stories whose dependencies are all `passed`
- Avoid circular dependencies

### Browser Validation
For UI stories, add `validation.type: "browser"` with steps:
```json
{
  "validation": {
    "type": "browser",
    "browserSteps": [
      { "action": "open", "target": "http://localhost:3000/page" },
      { "action": "wait", "target": "--text 'Expected Text'" },
      { "action": "snapshot", "expect": "description of what should be visible" },
      { "action": "screenshot", "path": ".leo/screenshots/US-XXX.png" }
    ]
  }
}
```

## Step 3: Create .leo/ Directory

Initialize the following files in `.leo/`:

### .leo/prd.json
```json
{
  "version": 2,
  "project": "<project name>",
  "branchName": "leo/<feature-slug>",
  "description": "<feature/project description>",
  "techStack": {
    "language": "<detected>",
    "framework": "<detected>",
    "buildCmd": "<detected or null>",
    "testCmd": "<detected or null>",
    "lintCmd": "<detected or null>",
    "typecheckCmd": "<detected or null>",
    "devServerCmd": "<detected or null>",
    "devServerUrl": "<detected or null>"
  },
  "phases": [
    { "id": "phase-0", "name": "Discovery", "type": "discovery", "status": "complete" },
    { "id": "phase-1", "name": "Foundation", "status": "pending" },
    { "id": "phase-2", "name": "Features", "status": "pending" },
    { "id": "phase-3", "name": "Polish", "status": "pending" }
  ],
  "stories": [
    {
      "id": "US-001",
      "title": "<title>",
      "description": "As a <user>, I want <goal>, so that <benefit>",
      "phase": "phase-1",
      "priority": 1,
      "skills": ["code", "database"],
      "dependsOn": [],
      "status": "pending",
      "failureCount": 0,
      "maxRetries": 3,
      "acceptanceCriteria": [
        "<criterion 1>",
        "<criterion 2>"
      ],
      "validation": {
        "type": "none",
        "browserSteps": []
      },
      "notes": "",
      "lastFailure": null
    }
  ]
}
```

### .leo/memory.json
```json
{
  "patterns": [],
  "decisions": [],
  "failures": [],
  "environment": {}
}
```

### .leo/quality-metrics.json
Run the project's quality commands and capture baseline:
```json
{
  "baseline": {
    "typescriptErrors": 0,
    "testCount": 0,
    "testPassRate": 1.0,
    "lintErrors": 0,
    "buildSuccess": true
  },
  "snapshots": [],
  "ratchetRules": {
    "typescriptErrors": "no-increase",
    "testCount": "no-decrease",
    "testPassRate": "no-decrease",
    "lintErrors": "no-increase",
    "buildSuccess": "must-be-true"
  }
}
```

For greenfield projects, set all baseline values to 0/true (baseline captured after scaffold story).

Also create `.leo/screenshots/` directory.

## Step 4: Show Summary & Confirm

Display to the user:
- Phase breakdown with story counts per phase
- Dependency graph (which stories block which)
- Skill distribution across stories
- Quality baseline (if existing project)
- Branch name
- Max iterations
- Command that will run

## Step 5: Start Loop

Ask user to confirm, then run:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/leo-wiggum.sh <max_iterations>
```

Pass `--headed` if user requested visible browser.

**CRITICAL:** After starting the script, END your response immediately. The script spawns NEW Claude Code sessions — your job is done.

## Monitoring

- **Terminal**: phase/iteration progress, quality gate results
- **`.leo/prd.json`**: story statuses and failure info
- **`.leo/memory.json`**: structured learnings, patterns, decisions, failures
- **`.leo/quality-metrics.json`**: metric trends across iterations
- **`.leo/screenshots/`**: visual proof from browser validation
- **`git log`**: commits per story
