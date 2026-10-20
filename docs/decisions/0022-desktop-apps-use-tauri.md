# 0022: Desktop apps in this repo use Tauri 2, unless a project has a reason not to

- Status: accepted
- Date: 2026-10-15
- Scope: `apps/desktop`. A starting default, not a rule for the whole repo.

## Context
The question "why Tauri?" had no answer in the repo. The owner's answer: it is a decent, fast app framework, and it is already familiar, so using it keeps the stack consistent across apps. This is a low-stakes choice, easy to change for a given app.

## Decision
Desktop apps start with Tauri 2: a Rust core with a webview UI, React and TypeScript for the UI ([0001](0001-frontend-react-vite.md)).

Nothing in this repo is the one way to build software. Other apps here may use other frameworks, each with its own playbook and standards. The `app-*` standards that name Tauri files and commands apply to Tauri apps.

## Pros and cons
Pros:
- Fast, with a small footprint: the skeleton's release binary is about 4 MB without an installer, and a cold release build took about a minute.
- Matches the stack already in use at work, so experience and fixes carry over.
- Native code lives in Rust, behind a narrow IPC boundary that is easy to test (a Rust test and a mocked UI test).

Cons:
- Two toolchains to keep current and tested: Rust and the web stack.
- The UI runs in each platform's own webview, so rendering can differ between operating systems. Only macOS (local) and Linux (CI) have been exercised, and only the skeleton.
- Audio played through a webview is not bit-perfect (see the draft audio notes), so hi-fi playback would have to run in the Rust core, not the web audio API.

## Consequences
New desktop apps default to this stack and the `desktop-app-setup` playbook. An app with a different need picks another framework and adds its own playbook and standards. Revisit if playback work shows the webview limit matters more than the benefits above.
