# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-27

### Added

Initial public release. Sanitized extraction of a private second-brain skill
that absorbed ~200 ingest cycles. Pipeline structure mirrors the canonical
"anchored synthesis" pattern for knowledge graphs.

- 7-step pipeline: existing-note gate, metadata, transcript, anchored reasoning,
  write, deep garden walk, verify post-write.
- Generic transcript script (`scripts/transcript.sh`) supporting yt-dlp
  auto-subtitles + whisper local fallback + SRT-to-TXT recovery.
- Config-driven paths (no hardcoded vault locations).
- Memory satellite gate (Step 5b) separating cross-applicable patterns from
  domain-specific notes.
- Backlink quality gate (3-7 total, >=2 synapse-class, distinguished from
  MOC/index links).
- Pre-emit cross-reference verify (Step 4.7.5) - tool-runnable check before
  writing memory satellite filenames, prevents drift between parallel writes.
- Wikilink verify (Step 4.9) - distinguishes vault-resolvable wikilinks from
  out-of-vault memory satellite references.
- Inline fact-check policy (Step 4.6) replacing `[unverified]` flags with
  cheap-tool inline verification.
- Verify post-write (Step 7) - read-back round-trip to catch silent write
  failures (sync delay, permission drift, MCP returning OK without disk write).
- 19 absorbed anti-patterns documented inline in SKILL.md.
- Philosophy document explaining the three driving principles
  (reasoning-is-the-neuron, anchored-synthesis, syntactic-vs-functional).
- MIT license.

### Design choices

- **No bundled LLM caller**: the skill is meant to run inside Claude Code or
  Claude Agent SDK, which already provide reasoning. Forks adapting to other
  agents are welcome but out of scope here.
- **No bundled vault adapter**: the skill assumes mcp-obsidian or equivalent.
  Adapters for Logseq, Foam, plain markdown are welcome contributions.
- **Whisper is a leaf dependency**: swap it freely (faster-whisper, deepgram,
  groq, etc.) by editing `scripts/transcript.sh`.

### Out of scope

- Bulk ingest (this is a top-down skill - one video at a time).
- Auto-tagging or classification heuristics that bypass the reasoning step.
- Cost-optimized external LLM tier routing (private extension, not portable).
