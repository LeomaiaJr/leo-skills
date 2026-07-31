---
name: orchestrating-codex
description: Use when a coding task could be handed to Codex/GPT instead of done in-house — bounded multi-file implementation, a second diagnosis after a failed fix, a pre-PR design challenge, or reviewing a diff before it ships. Also use when deciding whether to delegate at all.
---

# Orchestrating Codex

Claude is the tech lead. Codex is the implementer and the reviewer. The lead
scopes, decides, and accepts or rejects; the lead does not become the only pair
of hands in the room.

Requires the `codex@openai-codex` plugin. If Codex is missing or unauthenticated,
say so and stop — do not silently absorb the work.

## What the lead keeps

Never delegate these:

- **Framing** — what the actual problem is, and the root cause behind the symptom.
- **Approach** — architecture, the shape of the fix, which tradeoff wins.
- **Acceptance** — reading Codex's diff and deciding whether it ships.
- **The user relationship** — what gets reported, and how honestly.

## What goes to Codex

Delegate via the `codex:codex-rescue` subagent (defaults to `--write`, so it
edits files):

| Situation | Why Codex |
|---|---|
| Approach is decided, execution spans several files | Mechanical breadth, no judgment left to spend |
| Two of the lead's fix attempts failed | A fresh model beats a third hypothesis from the same one |
| Independent second diagnosis wanted before committing to a theory | Divergence is the point |
| Non-document coding work the lead would otherwise grind through | Matches the standing routing preference |

**Keep in-house instead when:**

- The task is **document, PDF, or extraction analysis** — that routes to
  Claude/Opus, always.
- The task needs **MCP tools** (Linear, PlanetScale, PostHog, Langfuse, Slack,
  browser). The Codex runtime is Bash-only; it cannot reach them.
- The handoff costs more than the edit. A one-file change is not a rescue.
- The next move is a **decision**, not a keystroke.

## Writing the handoff

Codex CLI reads the repo's `AGENTS.md` / `CLAUDE.md` natively. Do **not** re-paste
project invariants into the prompt — name the constraint that actually binds this
task and let the file carry the rest.

A handoff states: the goal, the root cause if already known, the files in scope,
and what "done" means. It does not include a solution the lead has not committed
to, and it does not include hedging.

## Review before it ships

Two layers, different jobs:

- **Stop review gate** (`/codex:setup --enable-review-gate`, per-workspace) —
  Codex reviews every edit-producing turn and can return `BLOCK`. This is the
  safety net; it runs without being asked.
- **`/codex:adversarial-review`** before opening a PR — challenges whether the
  approach itself is right. The gate catches defects; this catches wrong designs.
  It cannot be self-invoked, so the lead must ask the user to run it.

## Receiving Codex's output

Codex's verdict is evidence, not a ruling.

- **Verify each claim against the repo** before acting on it. Confirmed findings
  get fixed; unreproducible ones get named as such.
- **Reject work that violates a project invariant**, however confident the diff
  looks. Acceptance is the lead's signature.
- **Report the disagreement** when the lead overrides Codex. Silent overrides
  destroy the value of having a second reviewer.
- A `BLOCK` the lead believes is wrong is a conversation with the user, not a
  reason to disable the gate.

## Red flags

- Delegating because the problem is unclear → clarify first, then delegate.
- Delegating a decision → that is the lead's job.
- Pasting a whole `AGENTS.md` into a Codex prompt → it already read it.
- Accepting a Codex diff unverified → that is not review, that is laundering.
- Doing three hours of grinding implementation solo because delegation felt like
  admitting defeat → that is the failure this skill exists to prevent.
