# Prompt recipes

Each template is a complete `grok -p` argument. Replace `<ANGLE BRACKETS>`. All of
them carry the four required parts: named source, time window, output shape,
honesty clause.

## Trend scan — what is rising this week

```
Search X (Twitter) for what <AUDIENCE, e.g. AI engineers> have been posting about
in the last 7 days regarding <TOPIC>. Identify the 3 themes that multiple different
accounts are converging on, not one-off takes. For each theme give me 2 posts with
the author handle, the date, and the direct x.com URL. Separately list any theme
that appeared only once so I can tell signal from noise. If you cannot find real
posts, say NO_RESULTS.
```

The "multiple different accounts" and the one-off list are what stop a single loud
post from being reported as a trend.

## How people are actually building it

```
Search X (Twitter) for first-hand accounts from the last <N> days of engineers
building <THING> in production — real architectures, real numbers, real failures,
not roadmaps or listicles. Return 5 posts, each with the author handle, the date,
the specific technique or failure they describe, and the direct x.com URL. Exclude
promotional threads, course ads, and generic "10 tips" content. Then list what you
could NOT confirm. If you cannot find real posts, say NO_RESULTS.
```

The exclusion clause matters — without it a large share of results are marketing
threads. Grok will tell you when it filtered them out.

## Tool or library reception

```
Search X (Twitter) for what people who have actually used <TOOL> posted in the last
<N> days. Separate the results into: (a) concrete praise with a stated use case,
(b) concrete complaints or bugs, (c) promotional posts from the vendor or its
investors. Give the author handle, date, and direct x.com URL for each. Note how
many distinct accounts are in each bucket. If you cannot find real posts, say
NO_RESULTS.
```

Bucket (c) is the point — it makes the promotional share visible instead of blended
into the verdict.

## Did something actually ship

```
Search X (Twitter) and the web for whether <THING> was released or announced, and
when. Give me the primary source first — the official account or the changelog —
then what practitioners posted about using it in the first <N> days. Include the
date and direct URL for every item. Distinguish announced from generally available.
If the release did not happen or you cannot confirm it, say so plainly.
```

## What a specific person or lab has been saying

```
Search X (Twitter) for posts by @<HANDLE> in the last <N> days about <TOPIC>.
Summarize each post's actual claim in one sentence, with the date and direct
x.com URL. Do not include replies from other accounts or paraphrase beyond what
was posted. If there are no posts in that window, say so rather than reaching
further back.
```

The last clause stops the window from silently widening to fill the request.

## Cross-check a claim you already have

```
Search X (Twitter) and the web for evidence for AND against this claim: "<CLAIM>".
Give the strongest supporting source and the strongest contradicting source, each
with date and direct URL. State which side has better evidence and why. If the
claim cannot be confirmed either way, say that instead of picking a side.
```

## Machine-readable output

`--json-schema` is unreliable here — it returned `structuredOutput: null` with a
parse error in testing while the real answer sat in the text field. Ask for JSON in
the prompt body instead:

```
... Return your answer as a single fenced ```json block, an array of objects with
keys: handle, date, claim, url. No prose outside the block.
```

Then extract the fenced block. Add `--output-format json` only if you also want the
cost and token envelope; the answer still arrives in the `.text` field.
