# 0012: Conventions may be borrowed from other repos; content may not

- Status: superseded by [0016](0016-borrowing-from-referenced-repos-and-open-source.md)
- Date: 2026-10-15
- Scope: all sessions in this repo

## Context
`AGENTS.md` said never to mix in accounts or content from the owner's other organisations. The stack ([0001](0001-frontend-react-vite.md) to [0006](0006-ci-ubuntu-plus-macos-build.md)) and the git workflow ([0007](0007-git-workflow-issue-branches-conventional-commits.md)) were adapted from a repo the owner works in, at the owner's request. The rule and the practice needed a boundary.

## Decision
- Patterns and conventions from repos the owner works in may be adapted, and are checked before proposing something new.
- Names, content, accounts, paths and code are never copied. Decision records and memory name no other repo's paths, services or domains.
- Reading another repo is for the conventions the owner points to.

## Alternatives
- Ask each time: safest, but slows every session that could reuse a known pattern.
- No borrowing at all: keeps the repos fully independent, but throws away tested conventions.

## Dissent
Conventions from an employer's repos can carry the employer's IP. The reverse direction (work conventions into a personal repo) may need the same check. Accepted on the understanding that the owner confirms where needed.

## Consequences
Easier: sessions reuse known conventions without asking. Harder: sessions must paraphrase conventions rather than quote them. Revisit after the IP question is answered.
