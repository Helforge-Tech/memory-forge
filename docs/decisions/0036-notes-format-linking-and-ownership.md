# 0036: Notes have a small fixed format, link with relative markdown links, and live by who owns them

- Status: accepted
- Date: 2026-10-21
- Scope: the `memory-notes` standard, the `knowledge/` vault, the memory check

## Context
[#14](https://github.com/Helforge-Tech/memory-forge/issues/14). `knowledge/` is an Obsidian vault with no agreed note format, no linking rule (the open gap: wikilinks or relative links) and no rule for which notes are personal, which belong to a project and which are portable. [The memory design](../planning/MEMORY-ARCHITECTURE.md) fixes only "a title, a status, a date, and the links".

## Decision
- A note is one markdown file with front matter: `title`, `status` (`draft`, `active` or `superseded`) and `updated` (a date). The body is short and says one thing.
- Notes link with relative markdown links that include the `.md` extension. Wikilinks are not used.
- Ownership decides where a note lives:
  - **Portable** (domain understanding with no project or personal content): tracked, in `knowledge/domains/<name>/`, listed in `knowledge/INDEX.md`.
  - **Project** (how this project is built or why): in the project's `docs/`, never in the vault. It may link to portable notes.
  - **Personal** (preferences, scratch, anything about one person): `knowledge/personal/`, untracked by a `knowledge/.gitignore`.
- A note moves toward portable only by a human: strip the project and personal content, move it, add the index row. Sessions propose a candidate in the handoff; the owner promotes it in a PR.
- A portable note links only to portable notes. The memory check fails a dead link in a note and a link out of the vault.
- The vault ships an Obsidian setting for markdown links with relative paths, so a new link follows the rule without anyone remembering it.

## Alternatives
- **Wikilinks.** Faster to type in Obsidian, but GitHub and the memory check do not follow them, and a rename breaks them silently outside Obsidian.
- **Personal notes in a separate vault outside the repo.** Safest for privacy, but a second place to open, back up and forget; the ignored folder gives the same privacy with one vault.
- **Richer front matter (tags, aliases, a `scope` field).** Folder already says the scope; each extra field is one more thing to keep true. Add one when a task needs it.

## Dissent
Relative links are longer to write and break when a note moves, and a person who prefers wikilinks loses a convenience. Accepted: the link check catches the break, and Obsidian writes the relative link itself with the shipped setting. A project note that wants to mention a personal one cannot link to it (untracked), by design.

## Consequences
Easier: the vault reads the same on GitHub and in Obsidian, and links are checked. Harder: a personal note is lost with the machine unless the person backs it up. Not verified: that Obsidian applies the shipped setting (no Obsidian here); the first person to open the vault should confirm. Revisit when the first real notes show whether `status` and `updated` are kept up.
