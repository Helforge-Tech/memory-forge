# 0045: An area brief below the root is code for the PR split, because it names the area's files

- Status: accepted
- Date: 2026-11-06
- Scope: [git-split-code-and-memory](../../memory-kit/standards/git-split-code-and-memory.md) rules 1 and 4; supersedes the sentence of [0039](0039-nested-briefs-linked-from-parent-brief.md) that has a repo listing its briefs in `checks/split` list each nested brief as memory; narrows the memory side of [0031](0031-split-code-and-memory-prs.md) for these files

## Context
[0031](0031-split-code-and-memory-prs.md) puts guidance on the memory side of the split. An area brief is guidance, but its `## Code` section also lists the area's code paths, and the memory check (`brief-path-missing`, [memory-area-briefs](../../memory-kit/standards/memory-area-briefs.md)) fails when a listed path does not exist. In a project that followed 0039 and listed its nested briefs as memory, a rename of a briefed file could not pass both gates. If the code PR left the brief stale, `task memory` failed. If it updated the brief, `task split` failed the PR as mixed. Stacked in either order, the lower PR stayed red. The split check's defaults already treat only the root `AGENTS.md` as memory, so the deadlock came from following 0039's advice.

## Decision
- **An area brief below the root is code for the split.** It ships with the code it describes, in the same PR, so a rename and its `## Code` update pass `task split` together. A repo whose `checks/split` lists its briefs lists these as `code`, or leaves them unlisted (an unlisted path is code).
- **The memory check still validates every brief:** its size budget, its links, and that each `## Code` path exists. Nothing about the check changes.
- **A brief's guidance is reviewed with the code PR it rides in.** The root `AGENTS.md` stays memory.

## Alternatives
- **Exempt brief-only edits in the split check**, so a brief may sit beside code in either PR. Rejected: it is a hole in the check, which would pass any mix that contains a brief.
- **A temporary exception for the stale brief.** Rejected: it hides a real red behind an entry someone must remember to remove, and the next rename needs another.
- **Accept a red lower PR in a stack.** Rejected: every rename of a briefed file would be red by design, and an expected red gate stops meaning anything.

## Dissent
Brief wording (how an area runs, its rules) is now reviewed with the code, by the people who review code, not as memory. Limit: the memory check still validates it, and the reviewer reads it with the change it describes.

## Consequences
- A rename of a briefed file is one PR that passes both gates.
- A repo that builds images from whole folders and reads `checks/split` to decide what to rebuild should skip `AGENTS.md` by name, or a brief edit starts rebuilding images.
- A brief that lists only other briefs (a pure index) may stay memory; one that lists code paths is code.
