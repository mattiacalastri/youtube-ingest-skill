---
name: Anti-pattern report
about: You discovered a new failure mode of the pipeline. The skill should absorb it.
title: "[anti-pattern] "
labels: anti-pattern
assignees: ''
---

## Symptom

A short description of what went wrong. Be concrete: what did the skill produce, what did you expect, what was the gap?

## Pipeline step affected

Which step of the pipeline produced the unexpected behavior?

- [ ] Step 0 - existing-note gate
- [ ] Step 1 - metadata
- [ ] Step 2-3 - transcript
- [ ] Step 4 - reasoning
- [ ] Step 5 - write
- [ ] Step 5b - memory satellite
- [ ] Step 6 - deep garden walk
- [ ] Step 7 - verify post-write
- [ ] Brain-training sub-step (specify which)
- [ ] Other / cross-cutting

## Reproduction

```
# command that triggered the issue
/youtube-ingest <url> --mode <mode>
```

URL or characteristic of the source video (do not paste private content):

## Root cause hypothesis

What you think caused it. The pipeline is opinionated, so "the skill assumed X" answers are useful.

## Proposed absorption

How should the pipeline change to prevent this? The skill's design philosophy is to **absorb** anti-patterns into the pipeline, not to document them on the side. A proposed edit to SKILL.md is ideal.

## Environment

- OS: macOS / Linux / WSL
- Whisper backend: mlx_whisper / faster-whisper / other
- Vault adapter: Obsidian + mcp-obsidian / Logseq / plain markdown
- Claude Code / Agent SDK version:
