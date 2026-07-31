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

### grok-x-research

Research live X (Twitter) and the web through the Grok CLI — latest trends, what
practitioners are actually building, tool reception, anything past the training cutoff.

**Usage:** Just ask naturally:
- "What are people on X saying this week about building AI agents?"
- "Search X for how teams are running agents in production"
- "Use grok to check what shipped in the last few days"

**Requires** the official Grok CLI on PATH:
```bash
grok --version   # e.g. grok 0.2.112
```

**What it encodes.** Every detail was verified against `grok 0.2.112` by running it,
not read off docs:

- The binary is `grok`, not the unrelated community `grok-cli`. Agents reach for the
  wrong one and give up — this was the failure that motivated the skill.
- A four-part prompt contract (named source, time window, output shape, honesty
  clause) plus ready recipes for trend scans, "how are people building X", tool
  reception, launch checks, and tracking an account.
- Grok's search genuinely reaches X: across testing, 17/17 cited posts resolved to
  real posts whose text matched the claim.
- `--json-schema` is unreliable on research prompts — it returns
  `structuredOutput: null` while the real answer sits in `.text`.
- The built-in `deep-research` workflow, and the trap in it: launched headlessly the
  obvious way the process exits, its child agents are killed, and it writes a report
  saying *"No supported factual answer could be produced."* Keeping the session alive
  turns the identical query into a fully cited multi-agent report.
- `FS_PERMISSION_DENIED` recovery, including why relocating `GROK_HOME` with only
  `auth.json` turns a fast error into a silent multi-minute hang.

### orchestrating-codex

Decides when a coding task should be handed to Codex/GPT instead of ground through
in-house, and how to run the handoff. Claude is the tech lead; Codex is the
implementer and the reviewer.

**Usage:** triggers on its own when delegation is on the table:
- "Two fixes failed — get a second diagnosis"
- "Implement this across the auth files"
- "Review this diff before I open the PR"

**Requires** the `codex@openai-codex` plugin, authenticated.

**What it encodes:**

- What the lead never delegates — framing, approach, acceptance, the user
  relationship — versus what goes to Codex.
- The keep-in-house list: document/PDF/extraction analysis (routes to Claude/Opus),
  anything needing MCP tools (the Codex runtime is Bash-only), and edits cheaper
  than the handoff.
- Handoff shape: Codex reads the repo's `AGENTS.md` / `CLAUDE.md` natively, so
  pasting project invariants into the prompt is waste.
- Two review layers with different jobs — the stop review gate (catches defects,
  runs unasked) and `/codex:adversarial-review` (catches wrong designs, must be
  user-invoked).
- Receiving output: verdicts are evidence, not rulings. Verify each claim, reject
  invariant violations, and report overrides out loud.
