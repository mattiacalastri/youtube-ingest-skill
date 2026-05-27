# Quick Reference

One-page cheat sheet. Print it, pin it next to your terminal.

## Commands

```bash
# Standard mode (one neuron per video)
/youtube-ingest <url>

# Brain-training mode (active learning system)
/youtube-ingest <url> --mode brain-training

# Stop at reasoning, no write (preview)
/youtube-ingest <url> --no-vault

# Force container
/youtube-ingest <url> --container knowledge|persons|reference

# Force whisper language
/youtube-ingest <url> --lang it|en|auto

# Skip transcript steps, use existing file
/youtube-ingest --from-transcript /path/to/transcript.txt

# Brain-training only:
/youtube-ingest --review              # surface due reviews
/youtube-ingest --quiz <neuron-path>  # regenerate Q&A for existing neuron
```

## Weekly ritual (brain-training)

Sunday evening:

```bash
./scripts/brain-training-digest.sh
open ~/Desktop/brain-training-digest-$(date +%Y-%m-%d).md
```

Monday morning: schedule the week's deliberate ingest from the digest.

## Pipeline steps cheat-sheet

| # | Step | What |
|---|------|------|
| 0 | Existing-note gate | Check vault for this URL or speaker before transcribing |
| 0.5 | Speaker network | (brain-training) prospect/emerging/core classification |
| 1 | Metadata | oembed - title, author, language |
| 2-3 | Transcript | yt-dlp auto-sub OR whisper local |
| 4 | Reasoning | the actual value of the skill |
| 4.2 | Vault scan | parallel scan BEFORE reasoning, not after |
| 4.2.5 | Convergence | (brain-training) pattern asserted by 2+ speakers |
| 4.5.5 | Tension | (brain-training) claims contradicting prior neurons |
| 4.6 | Fact-check | inline, not flag-and-defer |
| 4.7.5 | Pre-emit verify | tool-runnable check before write |
| 4.9 | Wikilink verify | distinguish vault links from memory paths |
| 5 | Write | neuron file with quality-gated backlinks |
| 5b | Memory satellite | (gated) cross-applicable pattern only |
| 5.5 | Active recall | (brain-training) 5 Q&A per neuron |
| 5.6 | SR schedule | (brain-training) next_review set |
| 6 | Garden walk | second-pass synapse discovery |
| 6.5 | Cluster report | (brain-training) growth/stagnation |
| 7 | Verify post-write | read-back round-trip |

## Anti-pattern alarm bells

If you find yourself thinking any of these, stop:

| Thought | Reality |
|---------|---------|
| "I'll skip the garden walk this time" | You will lose 3-9 deep synapses |
| "Step 4.6 fact-check is overkill" | `[unverified]` is permanent narrative debt |
| "The vault scan can happen after reasoning" | That produces orphans, not neurons |
| "I'll write `[[wikilink]]` to a memory file" | It will not resolve |
| "5 Q&A is too many, 2 is fine" | Below 3, retention degrades |
| "I'll skip post-write verify, mcp returned OK" | OK != on disk |
| "This pattern only matters in this video" | Then it does not deserve a memory satellite |
| "I'll ingest 10 videos today, review tomorrow" | Tomorrow never comes. Rate-limit on recall |

## Backlink quality gate

- Min 3 total backlinks
- Max 7 total backlinks
- Min 2 synapse links (semantic, content notes)
- Index/MOC links count toward total but not toward synapse minimum

If you cannot find 3 real backlinks: this is the first neuron of the cluster. Note it explicitly in the body.

## Spaced repetition intervals (brain-training)

| Review # | Days from last |
|----------|----------------|
| 1 | 1 |
| 2 | 3 |
| 3 | 7 |
| 4 | 21 |
| 5 | 60 |
| 6+ | 180 |

Ease factor adjusts: smooth recall *1.1 (cap 3.0), failed recall *0.85.

## Network tier thresholds (brain-training)

| Prior neurons | Tier | Action |
|---------------|------|--------|
| 0 | prospect | tag, note signal evaluation |
| 1-2 | emerging | tag, explicit synapses to prior |
| 3+ | core | open Persons/X.md with Knowledge Library index |

Every 60 days: audit Persons/, demote stale prospects to `network: archived`.

## File locations (default config)

```
$VAULT_PATH/
  Knowledge Library/         neurons
  Persons/                   speaker profiles
  Clusters/                  topic MOCs
  Q&A/                       (brain-training) active recall
  Tensions/                  (brain-training) open contradictions
  Reviews/                   (brain-training) weekly digest archive
$MEMORY_DIR/                 out-of-vault memory satellites
$TRANSCRIPT_OUT/             VID_ID.txt + .srt + .meta.json
$AUDIO_CACHE/                cached audio (re-transcription)
$DEBUG_LOG                   transcript tool debug stream
```

## The three principles

1. Reasoning is the neuron, not the transcript.
2. Anchored synthesis beats isolated synthesis.
3. Syntactic success != functional success.

If a fork drops any of these, it is a different skill.
