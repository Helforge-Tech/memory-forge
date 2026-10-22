---
title: Notes have a small fixed format, link with relative markdown links, and live by who owns them
kind: memory
scope: portable
status: active
updated: 2026-10-21
decision: ../../docs/decisions/0036-notes-format-linking-and-ownership.md
check: memory-check.sh rules ref-missing and note-link-out on notes, tested by test-memory-check.sh in task test; task memory
---

# Notes have a small fixed format, link with relative markdown links, and live by who owns them

`<vault>/` below is the repo's notes folder (the Obsidian vault).

## Rule

1. **A note is one markdown file with front matter**: `title`, `status` (`draft`, `active` or `superseded`) and `updated` (a date). The body says one thing and stays short. Split a note that covers two.
2. **Link with relative markdown links that include `.md`** (`[title](../other/note.md)`). No wikilinks: they are not followed by GitHub or by the memory check.
3. **Where a note lives depends on who owns it:**

   | Kind | Holds | Where | Tracked |
   |---|---|---|---|
   | Portable | Domain understanding with no project or personal content | `<vault>/domains/<name>/` | yes, with a row in `<vault>/INDEX.md` |
   | Project | How this project is built, or why | the project's `docs/`, not the vault | yes |
   | Personal | Preferences, scratch, anything about one person | `<vault>/personal/` | no (the vault's `.gitignore`) |

4. **A project note may link to a portable note. A portable note links only to portable notes** (never to project files or personal notes).
5. **A note becomes portable only by a human.** A session that sees a candidate writes it in the handoff; the owner strips the project and personal content, moves it, adds the index row and merges it in a PR.
6. **The vault sets Obsidian to markdown links with relative paths** (`<vault>/.obsidian/app.json`), so a new link follows rule 2 by itself.
7. **The memory check enforces** `ref-missing` (a dead link in a tracked note) and `note-link-out` (a link that leaves the vault). Front matter and index rows are not checked; the reviewer looks. See [memory-checks](memory-checks.md).

## Why

- One format and one link style keep the vault readable on GitHub and in Obsidian, and let a check follow the links.
- Ownership by folder means nobody decides per note what is safe to share.

## Do / Don't

Do: write `See [audio latency](../audio/latency.md)` and put a tracked portable note in `<vault>/domains/audio/`.

Don't: put a project's decision in the vault, link a portable note to a project file, or write `[[latency]]`.

## Applied in

No example yet; the vault has no notes.
