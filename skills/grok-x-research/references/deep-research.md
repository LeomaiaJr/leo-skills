# deep-research

Grok ships a built-in multi-agent research workflow. It plans independent
sub-questions, researches them in parallel, has separate verifier agents
cross-check every claim against its cited source, and writes a report in which
unverified claims are dropped rather than softened.

Output quality is high — in testing every X citation it produced was a real post
whose text matched the summary. It is also slow (several minutes) and spends many
model calls. Use it when a single `grok -p` came back thin, or the question has
genuinely separable parts.

## The failure you must avoid

`/deep-research <query>` is a slash command in Grok's interactive TUI, so it is not
available to you. The agent-callable path is Grok's `workflow` tool. But the
workflow tool **returns immediately** and the run continues in the background — so
the obvious headless invocation launches the workflow and then exits, killing every
child agent mid-flight.

The run still completes and still writes a report. The report just says:

```
# Research result
**Status: Partial**
No supported factual answer could be produced.
```

This is not a bad query. It is the process having exited. Both failure modes below
were reproduced with the identical query.

## The command that works

Keep the session alive past the workflow with a `sleep`, then read the result:

```bash
grok -p 'Step 1: use the workflow tool to launch the built-in workflow named
"deep-research" with args {"query":"<QUESTION>","breadth":3} and agent_budget 12.
Step 2: immediately run this bash command to keep the session alive while it works:
sleep 300.
Step 3: after the sleep returns, report the final workflow result and the absolute
path of the report file.'
```

Budget the sleep generously — 300s handled `breadth: 2`. Give a wider run more.
If the sleep is too short you get the Partial report again, so err long.

Because this can outlast a normal command timeout, prefer running it in the
background and collecting the report file afterwards.

## Arguments

| Arg | Values | Notes |
|---|---|---|
| `query` | string | Required. `objective` also accepted. |
| `breadth` | 2–6, default 4 | Number of independent sub-questions. Each one costs a parallel researcher. |
| `agent_budget` | 1–1024, default 128 | Absolute cap on child-agent calls. Every researcher and verifier spends one. |

Keep `agent_budget` modest (8–16 for `breadth` 2–3). A run that exhausts its budget
can only be resumed by re-launching with a higher cap.

## Where the report lands

```
~/.grok/sessions/<url-encoded-cwd>/<session-id>/workflows/<run_id>/scratch/report.md
```

The run id is printed when the workflow launches. To find the newest report without it:

```bash
find ~/.grok/sessions -name report.md -mmin -30
```

Read `report.md` directly — it is the authoritative output, and it carries the
`## Sources` list with the `x.com` URLs behind each `[S1]`-style marker.

## Reading the result honestly

The report opens with a status line, and **`Status: Partial` is common even on good
runs** — it is set whenever any sub-question failed, any claim was dropped, or any
researcher logged an uncertainty. A Partial report with a full body and a Sources
list is a usable result with caveats; a Partial report whose body says "No supported
factual answer could be produced" is the early-exit failure above.

Check which one you have before reporting anything. Then pass the report's own
citations through to the user, and surface its "Coverage and uncertainty" notes
rather than dropping them.

## Constraints

- Workflows launch only from a top-level Grok session. A subagent cannot start one.
- A run interrupted by process restart is terminal — start a new run.
- One session holds a limited number of concurrent runs.
