# leo-skills

Custom Claude Code skills.

## Installation

```bash
/plugin marketplace add LeomaiaJr/leo-skills
/plugin install leo-skills@leo-skills
```

## Skills

### leo-wiggum

Autonomous coding loop that spawns fresh Claude Code sessions to implement features iteratively.

**Usage:** Just mention it naturally:
- "Use leo-wiggum to add a notifications feature"
- "Start leo loop for refactoring the auth module"

**How it works:**
1. Generates `prd.json` with user stories from your description
2. Runs external loop spawning fresh Claude sessions
3. Each session picks next incomplete story, implements, tests, commits
4. Memory persists via git, `prd.json`, and `progress.txt`

**Manual run:**
```bash
~/.claude/plugins/cache/leo-skills/leo-skills/*/skills/leo-wiggum/scripts/leo-wiggum.sh 10
```
