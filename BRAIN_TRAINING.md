# Brain Training Mode

> Use the skill as an active learning system, not a passive transcript saver.

This document explains how to configure `/youtube-ingest` for **deliberate brain training**: building a learning network of speakers, tracking convergences and tensions across videos, and using spaced repetition to retain what matters.

If you watch a lot of long-form content (talks, podcasts, technical interviews) and want each video to leave a lasting trace in your thinking, this is the mode for you.

## The problem brain-training mode solves

Default ingest mode produces a neuron per video. That is enough for a research notebook.

Brain-training mode produces a **learning system**: every neuron is part of a network that detects convergences, surfaces tensions, schedules reviews, and forces active recall. The vault becomes a brain you can train, not an archive you fill.

The cost is small: ~30s of additional processing per video and ~10min/week for the weekly digest.

## Activation

```
/youtube-ingest <url> --mode brain-training
```

Or set in `config.yml`:

```yaml
MODE: brain-training
```

When the mode is active, the standard pipeline gains six additional behaviors:

| Step | Standard | Brain-training |
|------|----------|----------------|
| 0.5 | n/a | Speaker network check |
| 4.2.5 | n/a | Convergence detection |
| 4.5.5 | n/a | Tension detection (cross-video) |
| 5.5 | n/a | Active recall generation |
| 5.6 | n/a | Spaced repetition scheduling |
| 6.5 | n/a | Cluster growth/stagnation report |

All six are described below.

## Six additional steps

### Step 0.5 - Speaker network check

After Step 0 (existing-note gate), check whether the speaker belongs to your active **learning network**.

```bash
SPEAKER_FREQUENCY=$(grep -l "author: <Speaker Name>" "$VAULT_PATH/$KNOWLEDGE_CONTAINER/"*.md | wc -l)
```

- **0 prior neurons**: first contact. Tag the new note with `network: prospect`. The body should note: "first ingest from this speaker - evaluate signal-to-noise."
- **1-2 prior neurons**: emerging. Tag `network: emerging`. Add explicit synapses to all prior neurons of the same speaker.
- **3+ prior neurons**: core. Tag `network: core`. Mandatory: open a `Persons/<Speaker>.md` if one does not exist, with a section `## Knowledge Library` listing all neurons.

Why: the speakers who shape your thinking deserve a dedicated node. Without this gate, your `Knowledge Library` accumulates orphans you cannot navigate by author.

### Step 4.2.5 - Convergence detection

During the parallel vault scan (Step 4.2), additionally scan for **converging claims**: a pattern, framework, or claim in the current video that is also asserted in 2+ prior neurons by **different** speakers.

```
For each extracted concept in Step 4.1:
    grep across vault for the concept's keyword OR semantic synonym
    if found in >= 2 prior neurons by different authors:
        flag as CONVERGENCE
```

In the neuron body, add a section:

```markdown
## Convergence

This video converges with prior thinking:
- [[Note A by Speaker X]] - same pattern, different framing
- [[Note B by Speaker Y]] - same pattern, applied to different domain

Convergence weight: HIGH (3+ independent sources) | MEDIUM (2 sources) | EMERGING (this is the second source)
```

Why: a pattern asserted by three independent thinkers is much stronger evidence than three repetitions of the same speaker. The vault should make this distinction visible.

### Step 4.5.5 - Tension detection

During tensions/contradictions extraction (Step 4.5), additionally scan for **claims in the current video that contradict claims in prior neurons**.

```
For each falsifiable claim in the current video:
    search prior neurons for opposing claims
    if found:
        flag as CROSS-VIDEO TENSION
```

In the neuron body, add a section:

```markdown
## Cross-video tension

This video contradicts prior notes:
- [[Note C by Speaker Z]] claims X. Current speaker claims NOT X.
  - Possible resolutions: (a) domain difference, (b) one is wrong, (c) timeline shift
- [[Note D]] asserts framework F. Current speaker rejects F as outdated.
```

Why: unresolved tensions in your graph are the most valuable signal for future research. They mark where your model of the world has an open question.

### Step 5.5 - Active recall generation

After writing the neuron (Step 5), generate **3-5 active-recall questions** and append them as a separate file in a `Q&A/` folder.

Path: `$VAULT_PATH/Q&A/<YYYY-MM-DD> - <Speaker> - <Topic>.md`

Format:

```markdown
---
type: active-recall
source: [[<neuron filename>]]
created: YYYY-MM-DD
next_review: YYYY-MM-DD+1
ease: 2.5
---

# Active recall - <Speaker> - <Topic>

## Q1
<question targeting the central thesis>
<details><summary>Answer</summary>
<answer pulled from neuron body>
</details>

## Q2
<question targeting an operational pattern>
<details>...

## Q3
<question targeting a tension or contradiction>
<details>...

## Q4
<question targeting a verified fact>
<details>...

## Q5 (synthesis)
<question that requires connecting to a prior neuron>
<details>...
```

Why: passive ingest does not build memory. Active recall does. Five questions per video is the threshold above which you reliably retain the central pattern at 30 days.

### Step 5.6 - Spaced repetition scheduling

Set `next_review` in the neuron frontmatter using a simple SM-2-inspired schedule:

| Review # | Interval | Set after |
|----------|----------|-----------|
| 1 | 1 day | ingest |
| 2 | 3 days | review 1 passed |
| 3 | 7 days | review 2 passed |
| 4 | 21 days | review 3 passed |
| 5 | 60 days | review 4 passed |
| 6+ | 180 days | thereafter |

Ease factor `ease: 2.5` decreases on failed recall (multiply by 0.85) and increases on smooth recall (multiply by 1.1, capped at 3.0).

The `--review` flag surfaces neurons whose `next_review <= today`:

```
/youtube-ingest --review
```

Output: list of neurons due, with one-click links to the matching `Q&A/` files.

### Step 6.5 - Cluster growth report

After the deep garden walk (Step 6), report on the **cluster** the new neuron joined:

```markdown
## Cluster report (this ingest)

Cluster: "AI agent evaluation"
- Neurons before this ingest: 8
- Neurons after: 9
- Last ingest in cluster: 12 days ago
- Speakers in cluster: 5 unique (this video adds 1 new)
- Open tensions in cluster: 2 (see [[Cluster: AI agent evaluation]])
```

Tag any cluster with **>60 days since last ingest** as `cluster: stagnant`. Surface in the weekly digest.

Why: brain training requires deliberate cluster coverage. Stagnant clusters are signal that your learning network has drifted from a topic you previously cared about. The vault should make that visible.

## Weekly digest

Run weekly (suggested: Sunday evening):

```bash
./scripts/brain-training-digest.sh
```

Output: `~/Desktop/brain-training-digest-YYYY-MM-DD.md` containing:

1. **Reviews due this week** - neurons whose `next_review` falls in the next 7 days.
2. **Convergences detected** - patterns asserted by 3+ speakers in the past 7 days.
3. **Unresolved tensions** - cross-video tensions opened in the past 30 days with no resolution note.
4. **Stagnant clusters** - clusters not touched in 60+ days.
5. **Top speakers** - speakers with most neurons in the past 30 days.
6. **Network gaps** - clusters with only 1 speaker (concentration risk).
7. **Active recall completion rate** - % of due `Q&A/` files actually reviewed.

The digest is plain markdown. Read it on Sunday, schedule the week's deliberate ingest and review on Monday.

## Vault structure for brain training

Recommended folder layout inside `$VAULT_PATH`:

```
Knowledge Library/        # neurons (one per video, type: video-knowledge)
Persons/                  # speaker profile notes, one per author
Clusters/                 # MOC per topic cluster
Q&A/                      # active recall files
Tensions/                 # open cross-video tensions, one per tension
Reviews/                  # weekly digest archive
```

Tags reserved by brain-training mode:

- `network: prospect | emerging | core`
- `cluster: <slug>`
- `cluster: stagnant`
- `convergence: high | medium | emerging`
- `tension: open | resolved`

## Cadence

The skill targets sustainable cadence, not maximum throughput. Suggested rhythm for active brain training:

- **Daily ingest**: 1-3 videos. More than that and you cannot do active recall properly.
- **Daily review**: 5-10 minutes on `Q&A/` files due today.
- **Weekly digest**: Sunday, 20-30 minutes. Read the digest, plan next week's deliberate ingest.
- **Monthly cluster review**: pick one cluster, re-read its top 5 neurons, look for emergent doctrine.

Anti-pattern: ingesting 10 videos a day with no review. The vault grows, your memory does not. Brain training is rate-limited by recall, not by ingest.

## Active recall is not optional

The single biggest mistake in second-brain workflows is treating the vault as the memory. The vault is not the memory. The vault is the **map** of memory. The actual memory lives in your brain, and it requires retrieval practice to consolidate.

Skipping Step 5.5 (active recall generation) reduces this skill to a fancier transcript saver. The five questions per video are the mechanism that turns ingestion into training.

If you find yourself skipping the questions, you do not want brain training. You want a research notebook. Switch back to standard mode.

## Speaker network curation

Every 60 days, audit your `Persons/` folder:

- Speakers with `network: core` and 5+ neurons - are they still informing your thinking, or are you in a parasocial loop?
- Speakers with `network: emerging` and 2+ neurons - promote to core or demote to one-off?
- Speakers with `network: prospect` and 1 neuron, ingested 60+ days ago, no follow-up - the signal was probably weak. Tag `network: archived`.

A good learning network has ~10 core speakers, 15-20 emerging, and a rotating fringe of prospects. More than 15 core speakers means your attention is too diffuse to train.

## Closing

Brain training is a commitment, not a feature flag. The mode just enforces the discipline. The actual training happens in the daily review and the weekly digest.

If you adopt this mode, commit to it for 90 days before evaluating. The compound effect of spaced repetition + convergence detection + tension tracking is invisible at 7 days and undeniable at 90.
