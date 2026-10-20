---
title: A desktop app signs users in through the system browser, keeps tokens out of the webview, and fails closed
kind: app
scope: portable
status: active
updated: 2026-10-19
decision: ../../docs/decisions/0023-desktop-auth-native-oauth-now-broker-later.md
check: reviewer
---

# A desktop app signs users in through the system browser, keeps tokens out of the webview, and fails closed

## Rule

1. **System browser, never an embedded webview,** for the identity provider's sign-in page.
2. **Loopback redirect on `127.0.0.1` with an OS-assigned port,** open only while one login is pending, with a timeout. Starting a new login cancels the pending one.
3. **PKCE (S256) and `state` on every login.** The verifier never leaves native code and never appears in a URL. The redirect carries a code and `state` only, never a token. A mismatched `state` is rejected.
4. **Native code owns the session.** Tokens live in native code. The webview receives the signed-in user's name, email and roles, never a token.
5. **Persist only the refresh token, in the OS keychain.** Not in a file, not in web storage. Access and ID tokens stay in memory.
6. **Verify the ID token** before trusting it: signature against the provider's published keys, issuer, audience, expiry, and a verified email.
7. **Access is an allowlist** of emails and domain patterns, each with roles. An empty, missing or invalid list admits nobody. The list is checked at sign-in and again when a session is restored.
8. **Protected native commands check the role themselves.** The UI hiding a button is not access control.
9. **Fail closed.** A failed verify, refresh or allowlist check means signed out, with the stored token removed.
10. **Sign-out revokes** the token at the provider (best effort) and deletes the stored one.
11. **Provider code sits behind one interface,** so a server-side broker can replace it without changing commands or UI.
12. **Credentials are set at build time, outside git.** A build without them disables sign-in with a clear message.

## Why

- Browser-based sign-in keeps the user's password away from the app and lets password managers and security keys work.
- Anything in the webview can be reached by a script injected there. Keeping tokens in native code and the keychain limits what such a script can take.
- A device-enforced allowlist stops unlisted accounts but not a patched binary, so data held on a server needs a broker that enforces access there.

## Do / Don't

Do: exchange the code in native code and emit only `{ name, email, roles }` to the UI.

Don't: put a token or the PKCE verifier in a URL, a log line, a file, or web storage.

## Suggested checks (not added yet)

- A test that fails if a command's return type or event payload contains a token field.
- A search in `task lint` for web-storage writes and for `csp: null` in the Tauri config.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
