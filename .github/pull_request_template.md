## What this PR changes

Brief description. Link to the issue if any.

## Pipeline impact

- [ ] No pipeline change (docs, examples, CI, typos)
- [ ] Pipeline step added / modified (specify which step)
- [ ] New mode or flag added
- [ ] Adapter for new vault / transcript / whisper backend

## Philosophy alignment

The skill is opinionated. Confirm your PR aligns with these principles:

- [ ] Reasoning remains the value, not transcription
- [ ] Anchored synthesis precedes isolated synthesis (vault scan before reasoning)
- [ ] Syntactic success != functional success (writes are verified)
- [ ] Anti-patterns absorbed into the pipeline, not documented on the side

If your PR conflicts with any of these, explain why in 2-3 sentences. PRs that quietly bypass the philosophy will be closed without merge.

## Anti-pattern absorbed (if applicable)

If this PR fixes a failure mode you discovered, paste a 1-line description here. It will be added to the SKILL.md "Lessons learned" section.

## Testing

- [ ] `bash -n scripts/transcript.sh` passes
- [ ] `bash -n scripts/brain-training-digest.sh` passes
- [ ] Ran end-to-end on at least one real video
- [ ] No private content in diff (vault paths, speaker names, sessions, secrets)

## Out of scope

If your PR is closed-source LLM cost routing, auto-tagging that bypasses reasoning, or bulk ingest - this is the wrong repo. See README "Contributing" section.
