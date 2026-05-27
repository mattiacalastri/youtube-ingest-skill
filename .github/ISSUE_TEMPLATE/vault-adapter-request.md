---
name: Vault adapter request
about: You want to use this skill with a markdown KG other than Obsidian.
title: "[adapter] "
labels: adapter
assignees: ''
---

## Target KG

Which knowledge graph tool do you want adapter support for?

- [ ] Logseq
- [ ] Foam
- [ ] Roam Research
- [ ] Dendron
- [ ] SilverBullet
- [ ] Plain markdown directory (no GUI)
- [ ] Other (specify):

## Required operations

The skill needs these vault operations. Which are supported / blocked in your target?

| Operation | Supported? | Notes |
|-----------|------------|-------|
| `search_notes(query)` returning paths | | |
| `read_note(path)` returning content | | |
| `write_note(path, body)` creating files | | |
| `patch_note(path, section, content)` appending sections | | |
| `list_files(dir)` for container traversal | | |
| Frontmatter parsing (YAML) | | |
| Wikilink resolution `[[name]]` | | |
| Tag handling | | |

## Existing automation / API

Does your target KG expose an API or MCP server we can wrap? Link or describe.

## Volunteer to implement

- [ ] I am offering to implement this adapter
- [ ] I am requesting someone else implement it
- [ ] I can help test once implemented

## Out-of-vault memory satellites

The skill writes some files **outside** the vault (memory satellites for cross-applicable patterns). Your target KG must tolerate this. Confirm:

- [ ] My target KG does not break if files exist outside its root
- [ ] My target KG can reference out-of-root files (or I am OK with prose-only references)
