---
name: grok-x-research
description: Use for Grok, the grok CLI, xAI, or any research on X (Twitter) and the live web. Covers latest trends, what practitioners are building and shipping right now, how teams run things in production, new launches, tool reception, and anything past the training cutoff. Runs the `grok` binary; prefer over any grok-cli skill.
---

# Grok X Research

Grok's search reaches live X (Twitter) posts and the web, and returns real author handles with real `x.com/<handle>/status/<id>` URLs. This is the fastest way to learn what practitioners are actually doing right now, as opposed to what documentation claims.

## The binary is `grok`

```bash
grok -p "<your research prompt>"
```

That is the whole interface. It prints the answer to stdout and exits, typically in 30–60s.

`grok-cli` is a **different, unrelated** community tool, and usually is not installed. If you find yourself typing `grok-cli`, or curling an installer from GitHub, stop — you want the `grok` binary already on PATH. Confirm with `grok --version`.

## Write the prompt with all four parts

Every research prompt you send must contain:

1. **The source, named** — "Search X (Twitter) for…". Naming X shifts what gets searched.
2. **A time window** — "in the last 7 days", "since <date>". Without one you get evergreen filler.
3. **The output shape** — "Return N posts, each with the author handle, the date, one concrete claim, and the direct x.com URL."
4. **An honesty clause** — "If you cannot find real posts, say NO_RESULTS instead of inventing any. List what you could not confirm."

Dropping part 2 or 3 is the usual reason a run comes back vague.

```bash
grok -p 'Search X (Twitter) for what engineers posted in the last 7 days about how they
are running AI agents in production. Return 5 posts, each with the author handle, the
date, the specific technique or failure described, and the direct x.com URL. Then list
what you could NOT confirm. If you cannot find real posts, say NO_RESULTS.'
```

See `references/prompt-recipes.md` for ready templates: trend scans, "how are people building X", tool reception, launch checks, and tracking a specific account.

## Report what Grok returned, with its links

Your answer to the user is built from what came back:

- Each substantive claim carries the handle and the `x.com` URL Grok gave for it.
- Dates stay attached — "posted 2026-07-24", not "recently".
- A short **Gaps** line covering what Grok said it could not confirm.
- Distinguish one person's opinion from a broadly repeated pattern. A single post is one practitioner's take; say so rather than promoting it to a trend.

Do not add posts, handles, or URLs that Grok did not return. If a claim matters and is cheap to check, open the URL and confirm before repeating it.

## Two things that do not work

**`--json-schema` is unreliable for research prompts.** In testing it returned `structuredOutput: null` with a parse error while the real answer sat in the text field. Use plain output and read it. If you need machine-readable results, ask for a fenced JSON block inside the normal prompt.

**`grok` with no `-p` needs a real terminal.** Non-interactive it exits with `Error: Device not configured`. Always pass `-p`.

## If your sandbox blocks it

Grok writes a session file under `~/.grok` on every run. A sandbox that denies writes there fails immediately with:

```
Couldn't create session: Permission denied.: {"code": "FS_PERMISSION_DENIED"}
```

The fix is to allow writes to `~/.grok`. If you cannot, relocate the whole home — and copy **both** files:

```bash
export GROK_HOME=/writable/path/grokhome
mkdir -p "$GROK_HOME" && cp ~/.grok/auth.json ~/.grok/config.toml "$GROK_HOME"/
grok --always-approve -p '<prompt>'
```

Copy both or it gets worse, not better. An empty `GROK_HOME` exits with `Not signed in`; a half-populated one can sit silently for minutes. **Grok printing nothing for minutes is a broken environment, not a slow search** — a normal run answers in 30–60s. Kill it and fix the home directory rather than retrying with more flags.

Do not set `GROK_HOME` when `~/.grok` is already writable.

## Going deeper

For a question that deserves parallel investigation and claim-by-claim verification rather than a single answer, Grok has a built-in `deep-research` workflow. It costs several minutes and many model calls, and **launching it headlessly the obvious way silently returns an empty report** — read `references/deep-research.md` before using it.

Reach for it only when a single `grok -p` has come back thin, or the question is genuinely multi-part. Most requests do not need it.

## Fast checks

| Situation | Action |
|---|---|
| `command not found: grok-cli` | Wrong binary. Use `grok`. |
| `Error: Device not configured` | You omitted `-p`. |
| Empty / generic answer | Add a time window and demand handles + URLs. |
| `FS_PERMISSION_DENIED` | Sandbox blocks `~/.grok`. See above — do not improvise a new `GROK_HOME`. |
| Silent for minutes, no output | Broken environment, not a slow search. Kill it and fix the home directory. |
| `Not signed in` | `GROK_HOME` points somewhere without `auth.json`. |
| Deep-research report says "Status: Partial / No supported factual answer" | The session exited early. See `references/deep-research.md`. |
