---
type: video-knowledge
url: https://youtu.be/EXAMPLE_VID
author: Jane Doe (Researcher, ExampleLab)
channel: ExampleLab Talks
duration_min: 47
date: 2026-01-15
language: en
tags: [agents, evaluation, knowledge-graphs, retrieval, lessons]
---

# Jane Doe - On Why Most Agent Benchmarks Are Vibe Benchmarks

> _"If your benchmark is a single number on a single dataset, you do not have a benchmark, you have a leaderboard entry."_

## Thesis

The current generation of agent benchmarks measures task completion rates on closed datasets that the underlying models have likely seen during pre-training. The result is a benchmark that rewards memorization disguised as agency. Real benchmarks should test the agent's ability to **discover** the right tool, not to execute a tool whose name is in the prompt.

## Key points

- Distinction between **closed-world** benchmarks (tool list given) and **open-world** benchmarks (tool list discovered).
- Tool-use accuracy in closed-world: 87% on GPT-class models. Open-world: 31%.
- Failure mode is not "wrong tool chosen" - it is "no tool considered."
- Verified: ExampleLab benchmark suite has 12.4k stars on GitHub (verified at ingest, accurate per claim of "around 12k").
- Anti-pattern: training agents against the benchmark they will be evaluated on. Benchmarks should expire.

## Anchoring

This video resonates with prior notes on **evaluation drift** and **the gap between syntactic and functional success**. The "no tool considered" failure mode is the same shape as silent failures in distributed systems: the operation returns success because the wrong scope was measured.

Concretely:
- Connects to [[Eval-Drift in Long-Running Agents]] - both papers argue that the artifact being evaluated changes faster than the evaluation tool.
- Connects to [[Open-World Tool Discovery Pattern]] - this video is now the canonical reference for the distinction.
- Tension with [[Closed-World Benchmarks are Useful for Regression]] - both can be true at once; the video does not address this.

## Action

1. **P1**: review the open-world subset of our current agent benchmark suite. If we have none, design one.
2. **P2**: cite this video in the eval section of any agent-related proposal going forward.

## Synapses

- [[Eval-Drift in Long-Running Agents]] - same failure-shape across different domains
- [[Open-World Tool Discovery Pattern]] - this is now the canonical reference
- [[Syntactic vs Functional Success]] - the deep doctrine the video manifests
- [[Closed-World Benchmarks are Useful for Regression]] - candidate counter-argument

## Deep synapses (garden walk)

- [[Goodhart's Law in ML Evaluation]] - ancestor doctrine: when a measure becomes a target it ceases to be a good measure
- [[Pre-training Contamination]] - sister scar across NLP eval literature
- [[Robustness vs Performance Tradeoff]] - the eval-design pattern lives here

---
*Ingested via /youtube-ingest. Transcript: ~/Desktop/transcripts/EXAMPLE_VID.txt*
