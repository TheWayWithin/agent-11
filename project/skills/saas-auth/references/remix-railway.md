# saas-auth — Remix + Railway reference

Stack-specific implementation for Remix on Railway with PostgreSQL, using Lucia Auth. Load this only when the project's stack matches. The main `SKILL.md` carries the stack-agnostic patterns; this file fills in the framework-specific glue.

## Setup

```bash
npm install lucia @lucia-auth/adapter-postgresql oslo
npm install -D @types/pg
```

## Lucia configuration

```typescript
// app/lib/auth.server.ts
import { Lucia } from 'lucia';
import { PostgresJsAdapter } from '@lucia-auth/adapter-postgresql';
import postgres from 'postgres';

const sql = postgres(process.env.DATABASE_URL!);

const adapter = new PostgresJsAdapter(sql, {
  user: 'users',
  session: 'sessions',
});

export const lucia = new Lucia(adapter, {
  sessionCookie: {
    attributes: {
      secure: process.env.NODE_ENV === 'production',
    },
  },
  getUserAttributes: (attributes) => {
    return {
      email: attributes.email,
      emailVerified: attributes.email_verified,
    };
  },
});

declare module 'lucia' {
  interface Register {
    Lucia: typeof lucia;
    DatabaseUserAttributes: {
      email: string;
      email_verified: boolean;
    };
  }
}
```

## Signup action

```typescript
// app/routes/auth.signup.tsx
import { ActionFunctionArgs, json, redirect } from '@remix-run/node';
import { lucia } from '~/lib/auth.server';
import { generateId } from 'lucia';
import { Argon2id } from 'oslo/password';
import { db } from '~/lib/db.server';

export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData();
  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  // Validate
  if (!email || !password || password.length < 8) {
    return json({ error: 'Invalid input' }, { status: 400 });
  }

  const hashedPassword = await new Argon2id().hash(password);
  const userId = generateId(15);

  try {
    await db.user.create({
      data: {
        id: userId,
        email: email.toLowerCase(),
        hashedPassword,
        emailVerified: false,
      },
    });

    const session = await lucia.createSession(userId, {});
    const sessionCookie = lucia.createSessionCookie(session.id);

    return redirect('/verify-email', {
      headers: {
        'Set-Cookie': sessionCookie.serialize(),
      },
    });
  } catch (e) {
    return json({ error: 'Email already exists' }, { status: 400 });
  }
}
```

## Session helpers

```typescript
// app/lib/session.server.ts
import { lucia } from './auth.server';
import type { Session, User } from 'lucia';

export async function getSession(
  request: Request
): Promise<{ user: User; session: Session } | { user: null; session: null }> {
  const sessionId = lucia.readSessionCookie(request.headers.get('Cookie') ?? '');

  if (!sessionId) {
    return { user: null, session: null };
  }

  const result = await lucia.validateSession(sessionId);
  return result;
}

export async function requireAuth(request: Request) {
  const { user, session } = await getSession(request);

  if (!user) {
    throw redirect('/login');
  }

  return { user, session };
}
```

## Required environment variables

```
DATABASE_URL=
SESSION_SECRET=
```
