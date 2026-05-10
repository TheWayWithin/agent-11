# Ideation — Tinylink

A tiny link shortener for individual users.

## Vision

A minimal web app where logged-in users paste a long URL, get a short one back, and can see click stats for their own links. Built for solo individuals who want a personal short-link namespace without paying Bitly, not for teams.

## Target user

Solo operators (writers, consultants, indie devs) who share links on social media and want (a) tidy branded-looking URLs and (b) basic per-link stats.

## Core features (MVP)

- **Auth**: email + password sign-up and sign-in. No OAuth yet.
- **Shorten a URL**: logged-in user pastes a long URL, gets a short code (e.g., `tinylink.app/x4Ka9`) back.
- **Redirect**: visiting the short URL redirects to the long URL and logs a click.
- **My links page**: logged-in user sees a list of their own links with total click count per link.
- **Delete a link**: soft delete — the short URL starts returning 404 after deletion.

## Non-goals (for MVP)

- Team accounts or shared workspaces.
- Custom domains.
- Detailed analytics (geography, referrers, time-series charts).
- Password reset / email verification (can be added post-MVP).
- Bulk import / export.

## Success criteria

- A new user can sign up, create a short link, visit it in an incognito window, and see the click counted on their "My links" page.
- Short-code collisions are handled (regenerated, never served to the wrong URL).
- Each user only sees their own links.
- The app survives a restart without losing data.

## Stack (suggestions, agent can choose)

- Any lightweight web stack is fine (Next.js, Remix, SvelteKit, or plain Express + a tiny frontend).
- SQLite or Postgres for storage.
- Keep it deployable to Railway / Vercel / Netlify without extra infra.

## Out of scope

- Marketing site, pricing page, landing page.
- Admin dashboard.
- Rate limiting (beyond sensible defaults).
- Fancy UI — functional is fine.
