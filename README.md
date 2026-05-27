# youtube-ingest-skill

> From a YouTube URL to a connected neuron in your knowledge graph.

A Claude Code / Claude Agent SDK skill that ingests YouTube videos as **structured, vault-anchored notes** in Obsidian (or any markdown knowledge graph). The skill is opinionated: it values **reasoning over summarization** and **graph-anchored synthesis over isolated transcripts**.

## What makes this different from `/yt-summarize` skills

Most YouTube-to-markdown skills do this:

```
URL -> transcript -> LLM summary -> markdown file
```

This skill does this:

```
URL
  -> existing-note gate (avoid blind re-ingest)
  -> metadata (oembed)
  -> transcript (yt-dlp + whisper local)
  -> reasoning anchored to your existing knowledge graph
     (vault scan -> backlinks -> cross-source verification)
  -> write note with quality-gated backlinks
  -> deep garden walk (second-pass synapse discovery)
  -> verify-post-write (sintattico != funzionale)
```

The valuable step is the **reasoning anchored to your existing graph**: where does this video touch concepts you already have notes on? That step is what turns a transcript into a neuron.

## Requirements

- [Obsidian](https://obsidian.md/) vault (or any markdown KG)
- [Claude Code](https://docs.claude.com/en/docs/claude-code) **OR** Claude Agent SDK
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) for transcript fetching
- [mlx_whisper](https://github.com/ml-explore/mlx-examples/tree/main/whisper) (Apple Silicon) or faster-whisper (generic) for ASR fallback
- [Obsidian Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin + [mcp-obsidian](https://github.com/MarkusPfundstein/mcp-obsidian) MCP server (for graph-aware reads/writes)

## Install

```bash
git clone https://github.com/<you>/youtube-ingest-skill.git
cd youtube-ingest-skill
cp config.example.yml config.yml
# edit config.yml: set VAULT_PATH, MEMORY_DIR, TRANSCRIPT_TOOL, etc.
```

Link the skill into your Claude Code skills directory:

```bash
ln -s "$(pwd)/SKILL.md" ~/.claude/skills/youtube-ingest/SKILL.md
```

(Adjust path if your skills live elsewhere.)

## Quickstart

In Claude Code:

```
/youtube-ingest https://www.youtube.com/watch?v=VID_ID
```

Or with flags:

```
/youtube-ingest <url> --no-vault          # stop at reasoning, no write
/youtube-ingest <url> --container persons # force container
/youtube-ingest <url> --lang it           # force whisper language
```

## Configuration

See [`config.example.yml`](./config.example.yml). The skill reads these paths:

| Variable | Description | Example |
|----------|-------------|---------|
| `VAULT_PATH` | Root of your Obsidian vault | `~/Documents/MyVault` |
| `MEMORY_DIR` | Directory for persistent agent memory files | `~/.claude/memory` |
| `TRANSCRIPT_TOOL` | Path to the transcript shell script | `./scripts/transcript.sh` |
| `TRANSCRIPT_OUT` | Where transcripts land | `~/Desktop/transcripts/` |
| `KNOWLEDGE_CONTAINER` | Default folder inside vault for ingested videos | `Knowledge Library` |
| `PERSONS_CONTAINER` | Folder for person-centric notes | `Persons` |
| `WHISPER_BIN` | Path to whisper binary | `~/.venv/bin/mlx_whisper` |

## Philosophy

Read [`PHILOSOPHY.md`](./PHILOSOPHY.md) before extending. Three principles drive the design:

1. **Reasoning is the neuron, not the transcript.** A skill that only transcribes-and-summarizes throws away the graph value.
2. **Anchored synthesis beats isolated synthesis.** The first vault scan happens **before** the reasoning, not after.
3. **Syntactic success != functional success.** Every write is verified post-hoc by reading back from disk.

## Pipeline

Detailed pipeline in [`SKILL.md`](./SKILL.md). Summary:

| Step | Purpose | Gate |
|------|---------|------|
| 0 | Existing-note gate | avoid blind re-ingest |
| 1 | Metadata via oembed | language auto-detect |
| 2-3 | Transcript (yt-dlp -> whisper fallback) | background |
| 4 | Reasoning anchored to vault | pre-emit cross-reference verify |
| 5 | Write neuron note | quality-gated backlinks (3-7, >=2 synapse) |
| 5b | Memory satellite (gated) | only if pattern is cross-applicable |
| 6 | Deep garden walk | second-pass synapse discovery |
| 7 | Verify post-write | read back, check frontmatter + backlinks |

## Example output

See [`examples/sample-note.md`](./examples/sample-note.md) for a canonical note structure.

## Lessons learned (anti-patterns)

The skill embeds anti-patterns discovered during ~200 ingest cycles. The full list lives in [`SKILL.md`](./SKILL.md). Highlights:

- **Whisper drift**: don't mix venv whisper with system whisper. Pin one.
- **Blind re-ingest**: always check if a note for this URL or speaker already exists. Default to additive update.
- **Wikilink-to-memory rot**: `[[wikilink]]` only resolves inside the vault. Memory files outside the vault must be referenced as paths in prose, not as wikilinks.
- **Pre-emit naming check**: verify the filename you are about to write does not collide and matches the pattern other agents are using in parallel.
- **Garden walk is mandatory**: first reasoning pass sees 6-7 synapses, second pass finds 3-9 more. Without the second pass the synthesis is shallow.
- **Verify post-write**: `write_note` returning OK does not mean the file is on disk (iCloud sync, TCC, path drift). Read it back.
- **Inline fact-check beats unverified flag**: when a claim is verifiable with a cheap tool call, do it inline. Don't pollute the vault with `[unverified]` flags that become permanent narrative debt.

## Contributing

The skill is opinionated. PRs welcome for:

- Generic transcript tool wrappers (faster-whisper, distil-whisper, deepgram, etc.)
- Vault adapters beyond Obsidian (Logseq, Foam, plain markdown)
- Language-specific reasoning prompts
- Anti-pattern discoveries (open an issue with reproduction)

Out of scope:

- Closed-source LLM cost optimizations (your fork, your call)
- Auto-tagging / classification heuristics that bypass the reasoning step

## License

MIT. See [LICENSE](./LICENSE).

## Acknowledgements

The skill grew out of ~200 ingest sessions inside a personal second-brain workflow. The pipeline structure mirrors the canonical "anchored synthesis" pattern from knowledge-graph research; the sintattico-vs-funzionale verify discipline mirrors postmortem patterns from distributed systems engineering applied to single-user knowledge work.
