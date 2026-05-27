# Philosophy

> The transcript is raw material. The reasoning is the neuron. The synapse is the graph. Without all three the video evaporates.

This file exists because the skill is opinionated. If you fork it, fork the philosophy too, or fork hard.

## Three principles

### 1. Reasoning is the neuron, not the transcript

A pipeline that goes `transcript -> LLM summary -> markdown file` discards the graph. The summary lives in isolation. Six months later you cannot find it, you cannot tell why it mattered, and you cannot trace its influence on later notes.

The valuable artifact is **the synthesis anchored to your existing graph**: which nodes does this video touch, where does it confirm or contradict prior notes, what doctrine does it strengthen or invalidate?

If you find yourself writing "Step 4: summarize," you are building a different skill. Stop.

### 2. Anchored synthesis beats isolated synthesis

The first vault scan happens **before** the reasoning, not after.

Why this order matters: a reasoning pass that scans the vault afterwards optimizes for "what is interesting in this video." A reasoning pass that scans the vault first optimizes for "where does this video touch my existing thinking." The second framing produces neurons. The first produces orphans.

In practice this means **Step 4.2 (parallel vault scan) precedes Step 4.3 (anchored reasoning)**. The order is not aesthetic. It is structural.

### 3. Syntactic success != functional success

A tool call returning `200 OK` does not mean the file is on disk. A `[[wikilink]]` that compiles in markdown does not mean it resolves in the graph. A backlink count >= 3 does not mean the backlinks are semantic.

Every write in this skill is verified by **reading back from disk**. Every wikilink is verified by **checking the target exists in the vault**. Every backlink count is verified by a **quality gate** (synapse vs index).

This is the discipline that separates "the skill ran" from "the skill produced a usable artifact."

The pattern is general. It applies beyond this skill. Watch for it in your own work: when the success signal lives in the tool that did the work, you are vulnerable.

## Anti-patterns

### Parafrasi (the paraphrase trap)

If your output note is a shorter version of the transcript, you have failed Step 4. The reasoning step must produce **structure**, not **reduction**. Structure means:

- patterns extracted as named primitives
- tensions identified explicitly
- synapses to existing notes with one-line justifications
- cross-source verification of falsifiable claims

A paraphrase produces none of these.

### The unverified flag trap

You hear something on a transcript, you are not 100% sure of the number, you write `[unverified]` and move on. This feels like discipline. It is not.

`[unverified]` is **permanent narrative debt**. Future reads see the flag and trust the note less. Other agents see the flag and propagate doubt. Six months later you do not remember what was unverified or why.

The discipline is **inline fact-check**: if the claim is verifiable with a cheap tool call (GitHub stars, search, registry API, MCP lookup), do it now. Embed the verified value. The cost in seconds is the same. The cost in narrative debt is zero.

Reserve `[verify retro]` only for the case where the verification tool is genuinely unavailable AND the claim is load-bearing. Then add the retry condition explicitly.

### The garden-walk skip

The first reasoning pass sees the immediate cluster of the video's topic. A **second pass** done **after** the note is written, with **focused vault scans on the body's key concepts**, finds a different layer: ancestor doctrines, cross-cluster manifestations, genealogical chains.

Skipping the second pass produces shallow neurons. They look fine. They will not survive six months in the graph.

### The skill-output blindness

The skill is itself an object in the graph. It can be wrong. It can drift. When the skill emits its own output, the skill should **read back its output and verify**.

This is recursive. The skill that teaches `syntactic != functional` must apply that principle to its own output.

### The closed feedback loop

Anti-patterns discovered during use must be **scribed into the skill**, not into a separate "lessons learned" file. A skill that does not absorb its own scars is a static artifact. A skill that does absorb them is alive.

The repo's `CHANGELOG.md` records this loop. Every minor version after 1.0 documents a scar that was absorbed.

## What this skill is not

- A summarizer. Use a one-shot prompt for that.
- A bulk ingester. See bottom-up graph builders for that.
- A transcript tool. The transcript tool is a leaf dependency, not the value.
- A general "save to Obsidian" plugin. The reasoning step is the point.

If you want any of the above, fork hard and remove Steps 0, 4.2, 4.7.5, 6, 7. What remains is `transcript -> summary -> markdown`. That is a different, simpler skill. Build it, don't bend this one.

## Closing

The skill is small. The philosophy is the point. Forking the skill without the philosophy will produce a worse version of an already-existing tool. Forking the philosophy is what makes a fork worth doing.
