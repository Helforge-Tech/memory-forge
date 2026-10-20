# 0023: Desktop sign-in uses native Google OAuth now, and an auth broker later

- Status: accepted
- Date: 2026-10-19
- Scope: `apps/desktop`. Auth for any other app type gets its own decision.

## Context
Later tasks in the desktop app must be protected from unauthorized use, so sign-in comes before features. A common pattern is a server-side broker that holds the identity provider's secret, applies an allowlist with roles, and issues its own tokens. This repo has no backend and the owner does not want to host a service yet. The goal is a production-quality sign-in that needs no hosted service, and that a broker can replace later.

## Decision
The app signs in with Google using the installed-app flow (RFC 8252):

- The system browser opens Google's consent page. Google redirects to a loopback port on `127.0.0.1` that the app opens for one login.
- PKCE and `state` are required. The PKCE verifier stays in Rust. The loopback receives only a code and `state`, never a token.
- Rust exchanges the code, verifies the ID token (signature against Google's keys, issuer, audience, expiry, `email_verified`, and the hosted domain for domain patterns), then checks the allowlist.
- The allowlist is built into the app: exact emails and `*@domain` patterns, each with roles. `admin` implies every role. An empty or invalid list admits nobody.
- Only the refresh token is stored, in the OS keychain. Access and ID tokens stay in memory. The webview never sees a token.
- Protected commands check the role in Rust, not in the UI.
- An `IdentityProvider` trait isolates the Google specifics, so a broker-backed provider can replace it without changing commands or UI.

## Pros and cons
Pros:
- Nothing to host, and no secrets beyond a Desktop-type client ID and secret that Google does not treat as confidential.
- Follows the standard for installed apps, so reviewers and tools expect it.
- Covers the points that matter: no verifier or tokens in URLs, `state` checked, tokens in the keychain, ID token verified.

Cons:
- The allowlist is enforced on the device. It stops accounts that are not listed, not someone who patches the binary. Server-side data will need the broker.
- Changing the allowlist means shipping a new build.
- No central revocation. Removing someone takes effect only when they update, or when Google revokes their session.

## Consequences
Work that reaches server-side data waits for the broker (a follow-up issue). Mobile sign-in is separate (deep links instead of loopback). The standard `app-auth` records the rules above for other apps.
