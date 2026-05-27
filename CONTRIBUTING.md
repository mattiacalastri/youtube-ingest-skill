# Contributing

Thank you for considering a contribution. Read this file before opening an issue or a PR.

## The skill is opinionated

This is not a generic YouTube-to-markdown tool. It is an opinionated pipeline that values **reasoning anchored to a knowledge graph** over transcription. Many design choices look excessive until you have used the skill for 30+ ingests. Trust the discipline before bending it.

If you disagree with a design choice, open a Discussion first. PRs that quietly bypass the philosophy will be closed without merge.

## In scope

Contributions in scope:

- **Vault adapters**: Logseq, Foam, Roam, Dendron, plain markdown. See `.github/ISSUE_TEMPLATE/vault-adapter-request.md` for the operation surface required.
- **Transcript backends**: faster-whisper, distil-whisper, deepgram, groq, whisper.cpp. Wrap them in `scripts/transcript.sh` style.
- **Language-specific reasoning prompts**: the reasoning step is language-agnostic in principle but better prompts per language are welcome.
- **Anti-pattern absorption**: discovered a failure mode? Open an issue with the report template, propose a pipeline change. The pipeline absorbs scars; it does not document them on the side.
- **Brain-training mode refinements**: spaced repetition algorithm tuning, convergence heuristics, tension detection improvements. Cite at least 30 days of usage data.
- **Documentation**: clearer explanation of philosophy, more example notes, troubleshooting guides for common environment issues.
- **CI improvements**: better privacy scans, more lint targets, integration tests against real videos (without polluting the repo with transcripts).

## Out of scope

Will be closed:

- **Cost-optimized external LLM tier routing**: this is a private extension. Fork and add to your own private layer.
- **Auto-tagging or classification heuristics that bypass the reasoning step**: the reasoning step is the point.
- **Bulk ingest (many URLs at once)**: this is a top-down skill. Bulk corpus is a different design problem with a different skill.
- **Closed-source dependencies**: every dependency must have a permissive open-source license.
- **AI-generated PR descriptions with no signal**: write your own. The maintainer reads carefully.

## Code style

- **Shell**: POSIX-portable where possible. Use `bash` shebang. Pass `bash -n` syntax check. Use `set -euo pipefail`. Quote all variable expansions.
- **Python**: Python 3.10+. Use f-strings. Type hints for any function over 5 lines. No frameworks; stdlib only unless absolutely necessary.
- **Markdown**: ATX headings only (`#`, not underlines). No trailing whitespace. Code blocks fenced with language hint when possible.
- **YAML**: 2-space indentation. Lowercase keys. Comments explaining non-obvious settings.

## Anti-pattern absorption discipline

When you discover a new failure mode:

1. **Reproduce it**: confirm it is not a one-off transient.
2. **Diagnose root cause**: not "it failed" but "the pipeline assumed X, the world had Y, mismatch occurred at step Z."
3. **Propose absorption**: a concrete edit to SKILL.md that prevents future occurrence. Adding a check, changing default, restructuring a step.
4. **Add to lessons**: append a numbered entry to the "Lessons learned" section in SKILL.md.

A PR that fixes a bug without absorbing it into the pipeline is incomplete. The absorption is the contribution.

## Privacy in PRs

Never paste:
- Your vault paths
- Speaker names from real videos you have ingested
- Transcript content
- Memory satellite filenames or content
- Session numbers, internal IDs, or workflow tags

The CI privacy scan blocks some of these. Use placeholders (`Jane Doe`, `ExampleLab`) like the canonical examples in `examples/`.

## Local development

Set up:

```bash
git clone https://github.com/mattiacalastri/youtube-ingest-skill.git
cd youtube-ingest-skill
cp config.example.yml config.yml
# edit config.yml with a TEMPORARY test vault (not your real one)
```

Smoke test locally:

```bash
bash -n scripts/transcript.sh
bash -n scripts/brain-training-digest.sh
python3 -c "import yaml; yaml.safe_load(open('config.example.yml'))"
```

End-to-end test (uses real network):

```bash
# Pick a short public video (<5min) for testing
./scripts/transcript.sh "https://www.youtube.com/watch?v=SHORT_VID" /tmp/yt-test/
ls /tmp/yt-test/
```

## Commit messages

```
<type>: <imperative summary, <72 chars>

<body explaining the why, not the what>

<reference issue if any: Fixes #123>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `ci`, `chore`.

## License

By contributing you agree your contributions are licensed under MIT (the project's license).

## Getting feedback fast

The maintainer reviews PRs roughly weekly. To speed up:
- Open a Discussion before a large PR
- Reference the philosophy section your change aligns with
- Include before/after examples
- Pass CI before requesting review

## Questions

Open a Discussion. Email is not monitored for this project.
