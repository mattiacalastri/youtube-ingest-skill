---
name: youtube-ingest
description: Ingest a YouTube URL as a connected neuron in a markdown knowledge graph. 7-step pipeline (metadata + transcript + anchored reasoning + write + memory satellite + deep garden walk + verify post-write). Use when a video is worth becoming a node, not just a transcript.
trigger:
  - "/youtube-ingest <url>"
  - "/yt <url>"
  - "absorb <url>"
  - "ingest <url>"
---

# /youtube-ingest

> From a YouTube URL to a connected neuron. Transcript is raw material. Reasoning is the neuron. Synapses are the graph.

## When to use

- A single video is worth becoming a structured node in your knowledge graph.
- You want the synthesis anchored to existing notes, not floating in isolation.
- You want anti-paraphrase discipline: structure, tensions, synapses, fact-checked claims.

## When NOT to use

- Bulk corpus ingestion (use a bottom-up graph builder).
- One-off summary you will never re-read.
- Audio is unavailable or video is age-gated past your tooling.

## Flags

```
/youtube-ingest <url>                       pipeline default (standard mode)
/youtube-ingest <url> --mode brain-training enable brain-training mode (see below)
/youtube-ingest <url> --no-vault            stop at reasoning, no write
/youtube-ingest <url> --container X         force container (knowledge|persons|reference)
/youtube-ingest <url> --lang it|en          force whisper language
/youtube-ingest --from-transcript P         skip steps 1-3, start from existing transcript file
/youtube-ingest --review                    surface neurons due for spaced-repetition review
/youtube-ingest --quiz <neuron>             regenerate active-recall Q&A for an existing neuron
```

## Modes

- **standard** (default) - 7-step pipeline, one neuron per video, no review schedule.
- **brain-training** - 7 steps + 6 additional sub-steps for active learning, convergence/tension detection, spaced repetition, and a weekly digest. See [BRAIN_TRAINING.md](./BRAIN_TRAINING.md) for full details.

## Configuration

Read paths from `config.yml` at repo root (or env vars). See `config.example.yml`.

```yaml
VAULT_PATH: ~/Documents/MyVault
MEMORY_DIR: ~/.claude/memory
TRANSCRIPT_TOOL: ./scripts/transcript.sh
TRANSCRIPT_OUT: ~/Desktop/transcripts/
KNOWLEDGE_CONTAINER: Knowledge Library
PERSONS_CONTAINER: Persons
WHISPER_BIN: ~/.venv/bin/mlx_whisper
```

## Pipeline

### Step 0 - Existing-note gate

Avoid blind re-ingest. The vault may already have the neuron OR the speaker may already have a dedicated note.

```bash
VID_ID=$(extract_from_url "$URL")
META=$(curl -s "https://www.youtube.com/oembed?url=$URL&format=json")
TITLE=$(echo "$META" | jq -r .title)
AUTHOR=$(echo "$META" | jq -r .author_name)

# Check A - exact VID_ID in vault frontmatter
EXISTING=$(grep -rln "youtu.be/$VID_ID\|watch?v=$VID_ID" "$VAULT_PATH" 2>/dev/null)

# Check B - speaker already has a knowledge-container note
SPEAKER_NOTES=$(find "$VAULT_PATH/$KNOWLEDGE_CONTAINER/" -iname "*$AUTHOR*" 2>/dev/null)

# Check C - speaker already has a persons-container note
PERSON_NOTE=$(find "$VAULT_PATH/$PERSONS_CONTAINER/" -iname "*$AUTHOR*" 2>/dev/null)
```

Decision tree:

```
Check A match -> [A] additive update | [B] skip | [C] overwrite. STOP, do not re-transcribe.
Check B match -> [D] new note + patch prior speaker notes with bidirectional backlinks.
Check C match -> [E] new note + patch the persons-container note with backlink.
All checks no -> [F] forge clean. Note this is the first neuron of this cluster.
```

Default without user input: [A], [D], [E], or [F] respectively.

### Step 1 - Metadata

```bash
curl -s "https://www.youtube.com/oembed?url=$URL&format=json"
```

Extract: title, author, thumbnail. Decide language from title (default `auto` for whisper).

### Step 2-3 - Transcript

Delegate to the transcript tool (see `scripts/transcript.sh`):

```bash
$TRANSCRIPT_TOOL "$URL" "$TRANSCRIPT_OUT"
```

Run in background. Duration is variable (30s - 10min).

Strategy:

1. yt-dlp auto-subtitles (fast, may fail on PO Token).
2. Fallback: yt-dlp audio + whisper local (mlx_whisper on Apple Silicon, faster-whisper elsewhere).
3. SRT-to-TXT recovery if auto-sub returns SRT only.

Output: `$TRANSCRIPT_OUT/$VID_ID.{txt,srt,meta.json}`

### Step 4 - Reasoning (the core)

Pre-flight: read the transcript. Do not write anything yet.

Sub-passes (order matters):

```
4.0 Skim 30s - overview, tone, structure
4.1 Node extraction:
    - persons mentioned
    - companies/brands mentioned
    - technical/strategic concepts
    - verbatim numbers (currency, percent, dates, valuations)
4.2 Parallel vault scan - for each node:
    search the vault for existing notes
    catalogue: EXISTING (real backlinks) vs ABSENT (candidate future nodes)
4.3 Anchored reasoning - the interesting pattern is not what the video says,
    it is WHERE the video touches your existing graph:
    - operational patterns replicable across domains
    - mental models, explicit or implicit
    - decision frameworks
    - cross-applicable patterns to your active projects
4.4 Killer quotes (3-7 max) - verbatim only, no paraphrase
4.5 Tensions/contradictions - what does the speaker say vs do?
                              which claims are fragile?
4.6 Cross-source inline verification - fact-check NOW, do not flag-and-defer.
    Triggers (if at least one):
    - GitHub stars/forks -> gh search repos
    - monetary amounts > 100k -> focused web search
    - headcount/users > 1k -> LinkedIn/web search
    - market share/equity -> web search 2 sources
    - partnership/acquisition -> web search
    - public roles/board seats -> LinkedIn
    - pre-2020 historical dates -> cross-source
    - NPM/PyPI stats > 10k -> registry API
    Execution:
    1. Tool call (~5s, cheap)
    2. Embed verbatim in reasoning: "Claim X -> verified value Y (delta -Z%)"
    3. If verified +-10% -> note body: "verified at ingest"
    4. If diverges > 10% -> patch immediately with verified value
    5. Only if tool is genuinely down -> flag "[verify retro - tool X down, retry by date]"
       with timestamp and explicit retry condition.
    Anti-pattern: never write "[unverified]" as default on a verifiable claim.
    Delegating verification to the future reader is permanent narrative debt.
4.7 Container decision:
    - intervieved person relevant to your network -> KNOWLEDGE_CONTAINER
    - person already in PERSONS_CONTAINER -> additive patch + new knowledge note
    - concept/tutorial -> KNOWLEDGE_CONTAINER
    - operational pattern that changes how you work -> ALSO memory satellite
4.7.5 Pre-emit cross-reference verify (tool-runnable check, not prose):
    For every memory satellite filename you plan to write:
    a. Decide candidate filename: feedback_<topic_slug>_<id>.md
    b. ls $MEMORY_DIR/$CANDIDATE - if exists, bump suffix or skip
    c. grep -rn $CANDIDATE_STEM $VAULT_PATH/$KNOWLEDGE_CONTAINER/ - if drift, rename pre-write
    d. After Step 5 write: ls + grep round-trip to confirm filename consistency
    Rule: forbidden to emit `path/file_X.md` or `[[file_X]]` before verifying
    file_X exists OR is the exact filename Step 5b will emit.
4.8 Devil's advocate - self-critique:
    - Am I paraphrasing or extracting structure?
    - Are the synapses I propose real or forced?
    - What might be drift/confabulation?
4.9 Wikilink verify - for every [[wikilink]] you propose:
    a. If target is slug-shaped (feedback_*, project_*, reference_*) it may be
       a memory satellite OUTSIDE the vault.
       find $VAULT_PATH -iname "*<keyword>*"
       find $MEMORY_DIR -iname "*<keyword>*"
    b. If a parallel vault version exists with different naming ->
       alias: [[vault-target|display name]]
    c. If no vault version exists ->
       do NOT use [[]]. Write "Memory satellite `path/file.md`" in prose.
    d. Anti-pattern: a wikilink that is syntactically correct [[]]
       but functionally broken (target outside the graph).
```

**Pre-flight before Step 5**: surface to the user:

```
REASONING DONE
- Container:    Knowledge Library
- Filename:     {Speaker} - {Topic Concise}.md
- Synapses:     N existing + M candidate
- Memory sat:   [none | feedback_xxx.md gate-passed]
- Tensions:     K found
Proceed to write?
```

The user can redirect before write.

### Step 5 - Write the neuron

Path: `$VAULT_PATH/$KNOWLEDGE_CONTAINER/{Speaker} - {Topic Concise}.md`

**Naming pattern**:

```
{Speaker Full Name} - {Topic Concise}.md
```

Examples:

```
Andrej Karpathy - From Vibe Coding to Agentic Engineering.md
Some Researcher - Generative Bionics Humanoid Robotics.md
```

**Frontmatter canonical**:

```yaml
---
type: video-knowledge
url: https://youtu.be/<VID_ID>
author: <Name> (<role/affiliation>)
channel: <Channel>
duration_min: <int>
date: YYYY-MM-DD
language: it|en|...
tags: [tag1, tag2, max-5]
---
```

**Body canonical**:

```markdown
# {Speaker} - {Topic}

> _"{killer quote #1 verbatim}"_

## Thesis
{3-5 lines - the speaker's central position}

## Key points
- {bullet, verbatim or tight synthesis}
- ...

## Anchoring
{where the video touches your active projects, prior notes, doctrines.
 Emerging patterns. Independent convergences. Confirmed/invalidated frameworks.}

## Action
1. P1: {concrete next action or "cognitive metabolism only"}
2. ...

## Synapses
- [[ExistingNote1]] - {why connected, one line}
- [[ExistingNote2]] - {why}
- [[CandidateFutureNote]] - {placeholder, why it would be worth forging}

---
*Ingested via /youtube-ingest. Transcript: $TRANSCRIPT_OUT/{VID_ID}.txt*
```

**Backlink quality gate**:

- Range: 3 <= N_total <= 7 real backlinks
- Quality: at least N_synapse >= 2 must be semantic synapse links (not MOC/index aggregators)

Distinction:
- **Synapse link**: a content note (specific concept, person, pattern).
- **Index link**: a MOC/aggregator note.

Only index links = weak weaving. If you cannot find 3 real with >=2 synapse:
- vault is too empty on this topic -> note "first neuron of this cluster" in body
- OR reasoning was lazy -> return to Step 4.2 with cross-cluster keywords

If you find more than 7 -> select top-7 by strength.

**Merge intelligent vs overwrite**:

```
if note exists at the target path:
    patch_note with appended section: "## Update (date)"
else:
    write_note with full body
```

**Reverse backlinks**:

If you link `[[PersonsContainer/X]]`, read that note. If it does not already have a backlink to the new neuron, patch it with a `## Knowledge Library` section containing `[[<new neuron>]]`. Bidirectional weaving in-line.

### Step 5b - Memory satellite (gated)

Only if the video introduces an **operational pattern that changes how you work**.

Candidates:
- cross-applicable pattern (e.g., "strategic investors before financial in seed")
- cognitive scar
- reusable mental model

NOT candidates:
- sector-specific knowledge -> only vault note
- network person -> only persons note

Path:

```
$MEMORY_DIR/{type}_{slug}_{id}.md
```

Append a pointer to your memory index file.

### Step 6 - Deep garden walk

After Step 5, ALWAYS, before declaring done.

```
6.1 Re-read the note just written (Read of the file)
6.2 For each key concept in the body, new focused vault scan:
    - search ancestor doctrines not seen in 4.2
    - search patterns in adjacent prior work
    - search "manifestations" of the frame across the vault
6.3 Genealogical chain: for each synapse found, climb one level:
    neuron -> scar -> ancestor doctrine -> general principle
6.4 Patch the note with section:
    "## Deep synapses (garden walk)"
    new synapses not present in Step 5 + note why they only emerged after
    the first pass (fractal chain).
6.5 Reverse backlinks bidirectional on the NEW links.
```

Expected output: +3 to +9 deep synapses beyond first pass. If 0 -> garden walk was lazy, repeat with cross-cluster keywords.

Anti-pattern: declaring "enough synapses in Step 5" and skipping Step 6. The difference between a shallow and a deep neuron is exactly this step.

### Step 7 - Verify post-write

`write_note` returning OK does not mean the file is on disk (iCloud sync, TCC permissions, path drift, MCP silent fail).

```
7.1 Read the note at the exact path from Step 5
7.2 Verify frontmatter contains: url: youtu.be/{VID_ID}, date: today
7.3 Verify body contains all backlinks declared in Step 5 + 6 (grep [[)
7.4 Verify reverse backlinks: for every note patched in 5/6,
    Read and confirm the patch section is present
7.5 If mismatch -> alert "POST-WRITE DRIFT", do NOT declare done.
    Possible causes:
    - sync delay (retry after 10s)
    - permission blocked (run context lacks file access)
    - path drift (vault root changed - verify VAULT_PATH)
    - write_note silent fail (MCP returned OK, file not on disk)
```

Final "done" output only after 7.5 passes.

## Final output to user

```
NEURON INGRAFTED
- Vault note:   Knowledge Library/{Speaker} - {Topic}.md
- Synapses:     5 existing + 2 candidate
- Memory:       feedback_strategic_investors_first.md
- Reverse:      [[SomeNote]] patched
- Transcript:   $TRANSCRIPT_OUT/{VID_ID}.txt
- Pattern:      "key one-line takeaway"
- Tension:      "speaker underweights X"
- Next action:  P1 applicable to project Y
```

## Lessons learned (anti-patterns to avoid)

The pipeline above embeds discoveries from a long run of ingest cycles. The principal anti-patterns, in order of how often they happen:

1. **Whisper drift duale** - two whisper binaries on the same system (venv + brew) drift independently. Pin one, document the path, use only that.
2. **Vault path invented** - a skill assuming `~/Documents/MyVault` when the vault is in an iCloud container. Always read the path from config, never hardcode.
3. **Tool reinvention** - if a transcript tool already exists in the repo or in your scripts directory, do not write a new one. Wrap it.
4. **Step 3 silent skip** - the value is in Step 4 (reasoning) + Step 6 (garden walk). Skipping either turns the skill into a transcript saver.
5. **Reasoning == paraphrase** - if your output note is a shorter transcript, Step 4 failed.
6. **Whisper output format singleton** - some whisper binaries take only one `--output-format`. Use `all` to get txt + srt + vtt in one run.
7. **Hardcoded language** - default to `auto` for whisper language detection. Hardcoded `en` produces empty/garbled transcripts on non-English content.
8. **Garden walk skip** - first pass finds 6-7 synapses, second pass finds 3-9 more genealogical synapses. The second pass is not optional.
9. **Transcript exit code lies** - the underlying tool may exit non-zero even when an SRT was produced. Recover by converting SRT to plain text post-fail.
10. **Auto-archive collision** - if a watcher relocates files in your output directory, the next tool to write there will race. Write to a stable path outside auto-managed dirs.
11. **LLM placeholder in filename** - if you use a template like `{Speaker} - {Topic}.md` and the LLM literally returns "sess.XXXX" or "ID-N", strip the placeholder post-LLM before writing.
12. **Existing-note blind re-ingest** - always run Step 0 before transcribing. Avoids overwriting prior work and burning budget.
13. **Wikilink-to-memory rot** - `[[wikilink]]` only resolves inside the vault. Memory files outside the vault must be referenced as paths in prose. See Step 4.9.
14. **Garden walk lived in lessons, not pipeline** - a scar documented in `## Lessons` is not yet absorbed. The fix is Step 6 promoted to a mandatory step.
15. **Verify post-write missing** - syntactic success (`write_note` returned OK) != functional success (file on disk readable). See Step 7.
16. **Documentary antibody != operational antibody** - a scar described in prose is not enforced at runtime. The fix is Step 4.7.5 with tool-runnable checks before emit.
17. **Silent stderr masks transient failures** - if your transcript tool silences stderr, transient yt-dlp failures are undebuggable. Log to a debug file even on success path.
18. **In-flight user observation should patch the neuron** - if the user observes something mid-ingest, patch the neuron verbatim with their observation. Do not bury it in a separate memory file.
19. **Inline fact-check beats unverified flag** - when a claim is verifiable in ~5 seconds, do it now. `[unverified]` is permanent narrative debt. See Step 4.6.

Each of these anti-patterns was discovered the hard way. The pipeline absorbs them. If you fork, do not drop the absorption mechanism.

## Brain-training mode sub-steps

When `--mode brain-training` is active, six additional sub-steps run in addition to the standard pipeline. Full specification in [BRAIN_TRAINING.md](./BRAIN_TRAINING.md). Summary:

### Step 0.5 - Speaker network check (after Step 0)

Check how many prior neurons exist for this speaker.

- 0 prior -> tag `network: prospect`, note "first ingest, evaluate signal."
- 1-2 prior -> tag `network: emerging`, add explicit synapses to prior neurons by same speaker.
- 3+ prior -> tag `network: core`, ensure `Persons/<Speaker>.md` exists with `## Knowledge Library` index.

### Step 4.2.5 - Convergence detection (during vault scan)

For each extracted concept, scan for the same pattern asserted by 2+ different prior speakers. If found, body gains a `## Convergence` section with weight (`HIGH | MEDIUM | EMERGING`) and synapse links.

### Step 4.5.5 - Tension detection (during tension extraction)

Scan prior neurons for claims that contradict claims in the current video. If found, body gains a `## Cross-video tension` section with possible resolutions and links to the contradicted notes. Tag `tension: open`.

### Step 5.5 - Active recall generation (after Step 5)

Generate 3-5 active-recall questions targeting: thesis, operational pattern, tension, verified fact, cross-graph synthesis. Write to `$VAULT_PATH/Q&A/<date> - <Speaker> - <Topic>.md` with frontmatter (`source`, `next_review`, `ease`).

See `examples/quiz-example.md` for canonical structure.

### Step 5.6 - Spaced repetition scheduling

Set `next_review` in the Q&A frontmatter using an SM-2-inspired schedule (1d, 3d, 7d, 21d, 60d, 180d). The `--review` flag surfaces neurons due today.

### Step 6.5 - Cluster growth report (after Step 6)

Report cluster the new neuron joined: neuron count before/after, last ingest in cluster, unique speaker count, open tensions. Tag clusters with >60 days since last ingest as `cluster: stagnant`. Surface in the weekly digest.

### Weekly digest

Run `scripts/brain-training-digest.sh` weekly. Produces a markdown digest covering reviews due, convergences detected, unresolved tensions, stagnant clusters, top speakers, network gaps, and active-recall completion rate.

## Sister skills (out of scope here)

- Bottom-up bulk graph builder for many URLs at once.
- Call/meeting transcript ingestion (different source, different metadata).
- Cross-cluster audit of the graph (orphan detection, weak weaving).
- Memory satellite cluster gardener.

These are different skills. Fork separately.
