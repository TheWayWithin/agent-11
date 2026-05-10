# Tinylink — User Stories (Phase 1)

**Mission**: BUILD Tinylink MVP
**Source**: `ideation.md`
**Author**: Coordinator (Phase 1, acting in @strategist role — Task delegation unavailable in nested subagent)
**Date**: 2026-05-03
**Status**: Draft for user review before Phase 2

---

## Stories

### S1 — Sign up with email and password

**As a** prospective user
**I want** to create an account with my email address and a password
**So that** I have a personal namespace where my short links live

**Acceptance criteria**

1. Given I am not signed in, when I visit `/signup`, I see a form with email and password fields.
2. Given a valid email and a password of at least 8 characters, when I submit the form, my account is created and I am signed in.
3. Given an email already registered, when I submit the form, I see an error ("an account with this email already exists") and no duplicate account is created.
4. Given an invalid email format, when I submit the form, I see a validation error and no account is created.
5. Given a password shorter than 8 characters, when I submit the form, I see a validation error and no account is created.
6. Passwords are stored hashed (bcrypt or argon2 — implementation detail, but never plaintext).

**Edge cases**

- Email casing: treat `Foo@Bar.com` and `foo@bar.com` as the same account (lowercase on storage).
- Whitespace around the email is trimmed before validation.
- Submitting the form twice in quick succession does not create two accounts (idempotent on email).

---

### S2 — Sign in with email and password

**As a** registered user
**I want** to sign in with my email and password
**So that** I can access my links

**Acceptance criteria**

1. Given a registered email and the correct password, when I submit `/login`, a session is established and I am redirected to `/my-links`.
2. Given a registered email and the wrong password, when I submit, I see a generic error ("invalid email or password") and no session is created.
3. Given an unregistered email, I see the same generic error (do not leak account existence).
4. The session persists across page reloads.
5. The session persists across server restart (cookie-based, signed; session record stored or stateless JWT — architect's choice).
6. There is a sign-out action that invalidates the session.

**Edge cases**

- Five consecutive failed logins for the same email within a short window are throttled (basic defense — exact threshold is the architect's call within "sensible defaults").
- Signing in while already signed in just refreshes the session.

---

### S3 — Shorten a URL

**As a** signed-in user
**I want** to paste a long URL and get back a short code
**So that** I can share a tidy link

**Acceptance criteria**

1. Given I am signed in, when I submit a valid `https://` or `http://` URL, I get back a short code (e.g., `x4Ka9`) and the full short URL (e.g., `https://tinylink.app/x4Ka9`).
2. The short code is unique across all links (collision handling — see edge cases).
3. The link is associated with my user account; other users cannot see or use it via `/my-links`.
4. The short code uses URL-safe characters only (alphanumeric is sufficient).
5. The short code is at least 5 characters long (collision space ≥ 60M for alphanumeric).

**Edge cases**

- **Collision on generation**: if a generated code already exists in the database (active or soft-deleted), regenerate. Bound the retry loop (e.g., max 5 attempts) and return a 500 with a clear error if exhausted — this is essentially impossible at MVP scale but must not silently fail.
- **Malformed URL**: missing scheme, missing host, javascript: scheme, mailto: scheme, or other non-http(s) schemes are rejected with a 400 and a validation message.
- **Excessively long URLs** (e.g., > 2048 chars) are rejected with a 400.
- **Whitespace** in submitted URL is trimmed before validation.
- Submitting the same long URL twice produces two distinct short codes (no dedup in MVP — keep it simple).

---

### S4 — Redirect on short-link visit

**As a** anyone with the short URL (signed in or not)
**I want** visiting the short URL to send me to the original long URL
**So that** the link works as a normal hyperlink

**Acceptance criteria**

1. Given a valid, non-deleted short code, when anyone (signed in or not) visits `/<code>`, they receive a 302 (or 301 — architect's call, prefer 302 to avoid aggressive caching) redirect to the long URL.
2. The visit is recorded as a click against the link's owner's record.
3. Click counting is best-effort: if logging fails, the redirect still succeeds (do not block redirect on logging).
4. Redirect path is server-side, not client-side (no JS bounce).

**Edge cases**

- **Soft-deleted short code**: returns 404, not redirect, even if the code was once valid (see S5).
- **Non-existent short code**: returns 404.
- **Case sensitivity**: short codes are case-sensitive. `x4Ka9` and `x4ka9` are different codes (avoid casing collisions in generation).
- **Bots / preview crawlers**: every GET counts as a click in MVP. No bot filtering. Documented as a limitation in the README.
- **Redirect loop guard**: not required for MVP — we control short-code generation, so a tinylink-to-tinylink redirect cannot occur naturally.

---

### S5 — My links page

**As a** signed-in user
**I want** to see a list of my own links with click counts
**So that** I can track which links are getting traction

**Acceptance criteria**

1. Given I am signed in, when I visit `/my-links`, I see a list of every link I have ever created that is not soft-deleted.
2. Each row shows: the short URL (clickable), the long URL (truncated if long), total click count, creation timestamp.
3. The page shows only my links — never any other user's links.
4. Empty state: when I have no links, I see a friendly message and a path to creating one.

**Edge cases**

- **Unauthenticated access**: visiting `/my-links` while signed out redirects to `/login` (or returns 401 for an API request — architect chooses based on whether the page is server-rendered or API-driven).
- **Cross-user attempt**: if a request includes a user identifier that does not match the session, the request is rejected (server enforces ownership; never trusts client-supplied user IDs).
- **Sort order**: most recent first by default. No filtering or pagination in MVP (acceptable assumption: a personal user has tens of links, not thousands).

---

### S6 — Soft-delete a link

**As a** signed-in user
**I want** to delete a link I no longer want
**So that** the short URL stops working without me losing the historical click count record

**Acceptance criteria**

1. Given I am signed in and viewing `/my-links`, when I click "delete" on one of my links, the link is marked deleted (soft delete — `deleted_at` timestamp set, row retained).
2. After deletion, visiting the short URL returns 404 (see S4 edge cases).
3. After deletion, the link no longer appears on `/my-links`.
4. The historical click count is preserved in the database (not exposed in MVP UI, but the data is not destroyed).
5. Deletion is idempotent — deleting an already-deleted link is a no-op (returns success).

**Edge cases**

- **Cross-user delete attempt**: user A cannot delete user B's link. Server returns 404 (preferable to 403 to avoid revealing existence).
- **Short-code reuse after soft-delete**: short codes are NOT recycled. A soft-deleted code stays reserved (this is why generation must check against all codes, not just active ones — see S3 edge cases).

---

## Cross-cutting requirements

- **Per-user isolation** is non-negotiable. Every read/write that touches links must scope by `owner_user_id` server-side. No client-supplied user identifiers are trusted.
- **Persistence**: data survives server restart. SQLite file or Postgres database — both satisfy this. In-memory storage is rejected.
- **No OAuth, no password reset, no email verification** in MVP. Documented limitation: forgotten passwords mean a lost account in v1.

---

## Confirmed scope vs non-goals

**In scope** (this MVP)

- Email + password sign-up / sign-in
- Shorten + redirect with click counting
- Per-user "My links" view
- Soft-delete returning 404
- Persistence across restart
- Server-side per-user isolation

**Out of scope** (locked — surface as vision-check if these come up)

- Team accounts / shared workspaces
- Custom domains
- Detailed analytics (geography, referrers, time-series)
- Password reset / email verification
- Bulk import / export
- Marketing / pricing / landing pages
- Admin dashboard
- Rate limiting beyond sensible auth-throttle defaults
- Fancy UI / design system / themes

---

## Success metrics / KPIs (MVP-level)

These are signals an operator can check manually after build, not production SLOs.

1. **Acceptance scenario** (the canonical one from ideation): a brand-new account can sign up, create a short link, click it in an incognito window, and see the click count on `/my-links` increment. End-to-end test must cover this.
2. **Per-user isolation**: an automated test signs in as user A, creates a link, signs in as user B, and confirms B cannot see A's link in `/my-links` and cannot delete it via direct API call. Test must pass.
3. **Soft-delete enforcement**: 100% of soft-deleted short codes return 404 on subsequent visits. Test must pass.
4. **Collision handling**: a unit test that simulates a collision (forces the generator to produce a known-existing code on first try) confirms regeneration succeeds and a unique code is returned.
5. **Persistence**: integration test creates data, restarts the app process, queries the data, and confirms it is still present.

Redirect latency, throughput, and other performance numbers are NOT MVP success criteria. The app is for personal use; "feels instant on my laptop" is sufficient.

---

## Open questions

None. Ideation is clear enough on all five core areas. Stack choice is a deliberate user gate at start of Phase 2, not an open question for the strategist.

---

## Architectural constraints implied by these stories

For @architect (Phase 2), these stories imply:

- **Server-side rendering or server-side redirect** is required for S4 (no JS bounce). Static-site-only stacks like pure Next.js export are unsuitable. Stacks that support server routes (Next.js app router, Remix, Express, SvelteKit with adapter) are all fine.
- **Session-based auth** is the natural fit. JWT works too but session cookies are simpler and meet the "persists across restart" criterion if the session record is in the database. Architect chooses, but flag if going stateless JWT.
- **Single-process deployable** to Railway / Vercel / Netlify. SQLite works on Railway with a persistent volume; on Vercel/Netlify you typically need Postgres because the filesystem is ephemeral. This affects the stack-options menu for the user gate.
- **Click logging must not block the redirect path**. Either fire-and-forget (background) or commit-then-redirect with a tight DB write. Architect's call.
