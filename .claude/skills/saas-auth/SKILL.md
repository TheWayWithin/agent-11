---
name: saas-auth
version: 1.0.0
category: authentication
triggers:
  - auth
  - authentication
  - login
  - signup
  - sign up
  - sign in
  - password
  - session
  - jwt
  - oauth
  - social login
  - google login
  - github login
  - email verification
  - password reset
  - magic link
specialist: "@developer"
stack_aware: true
complexity: intermediate
estimated_tokens: 3800
dependencies: []
---

# SaaS Authentication

## Capability

Implement production-ready authentication for SaaS applications including email/password, OAuth social login, session management, and security best practices. This skill covers the complete auth lifecycle from signup through password recovery.

## Use Cases

- User registration with email verification
- Login with email/password or social providers
- Password reset and recovery flows
- Session management and token handling
- Rate limiting and brute force protection
- Multi-factor authentication setup

## Patterns

### Email/Password Authentication

**When to use**: Standard SaaS signup/login flow with email verification

**Implementation**: Create registration endpoint that hashes password, stores user, sends verification email. Login validates credentials and creates session.

```typescript
// Registration flow
async function register(email: string, password: string) {
  // 1. Validate email format and password strength
  validateEmail(email);
  validatePasswordStrength(password); // min 8 chars, mixed case, number

  // 2. Check if user exists
  const existing = await findUserByEmail(email);
  if (existing) throw new Error('Email already registered');

  // 3. Hash password with bcrypt (cost factor 12)
  const passwordHash = await bcrypt.hash(password, 12);

  // 4. Create user with unverified status
  const user = await createUser({
    email,
    passwordHash,
    emailVerified: false,
    createdAt: new Date()
  });

  // 5. Generate verification token (expires in 24h)
  const token = generateSecureToken();
  await storeVerificationToken(user.id, token, 24 * 60 * 60);

  // 6. Send verification email
  await sendVerificationEmail(email, token);

  return { success: true, message: 'Check email for verification link' };
}
```

### OAuth/Social Login

**When to use**: Allow users to sign in with Google, GitHub, or other OAuth providers

**Implementation**: Configure OAuth provider, handle callback, link or create account.

```typescript
// OAuth callback handler
async function handleOAuthCallback(provider: string, code: string) {
  // 1. Exchange code for tokens
  const tokens = await exchangeCodeForTokens(provider, code);

  // 2. Get user profile from provider
  const profile = await getOAuthProfile(provider, tokens.access_token);

  // 3. Find or create user
  let user = await findUserByOAuthId(provider, profile.id);

  if (!user) {
    // Check if email exists (account linking)
    user = await findUserByEmail(profile.email);
    if (user) {
      // Link OAuth to existing account
      await linkOAuthAccount(user.id, provider, profile.id);
    } else {
      // Create new user
      user = await createUser({
        email: profile.email,
        name: profile.name,
        avatar: profile.avatar,
        emailVerified: true, // OAuth emails are pre-verified
        oauthAccounts: [{ provider, providerId: profile.id }]
      });
    }
  }

  // 4. Create session
  return createSession(user.id);
}
```

### Session Management

**When to use**: Managing authenticated user sessions securely

**Implementation**: Use httpOnly cookies for session tokens, implement refresh token rotation.

```typescript
// Session creation with secure cookies
async function createSession(userId: string) {
  // Generate cryptographically secure session ID
  const sessionId = crypto.randomBytes(32).toString('hex');

  // Store session in database with expiry
  await storeSession({
    id: sessionId,
    userId,
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
    createdAt: new Date(),
    userAgent: request.headers['user-agent'],
    ip: request.ip
  });

  // Set httpOnly cookie (never accessible to JavaScript)
  return {
    cookie: {
      name: 'session',
      value: sessionId,
      options: {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        maxAge: 7 * 24 * 60 * 60, // 7 days in seconds
        path: '/'
      }
    }
  };
}

// Session validation middleware
async function validateSession(request: Request) {
  const sessionId = request.cookies.get('session');
  if (!sessionId) return null;

  const session = await getSession(sessionId);
  if (!session || session.expiresAt < new Date()) {
    return null;
  }

  // Extend session on activity (sliding expiration)
  if (session.expiresAt < new Date(Date.now() + 3 * 24 * 60 * 60 * 1000)) {
    await extendSession(sessionId, 7 * 24 * 60 * 60 * 1000);
  }

  return session;
}
```

### Password Reset Flow

**When to use**: User forgot password and needs to recover account

**Implementation**: Generate time-limited token, send email, validate and update password.

```typescript
// Request password reset
async function requestPasswordReset(email: string) {
  const user = await findUserByEmail(email);

  // Always return success to prevent email enumeration
  if (!user) {
    return { success: true, message: 'If email exists, reset link sent' };
  }

  // Rate limit: max 3 reset requests per hour
  const recentRequests = await countResetRequests(email, 60 * 60);
  if (recentRequests >= 3) {
    return { success: true, message: 'If email exists, reset link sent' };
  }

  // Generate secure token (expires in 1 hour)
  const token = crypto.randomBytes(32).toString('hex');
  const tokenHash = await bcrypt.hash(token, 10);

  await storePasswordResetToken({
    userId: user.id,
    tokenHash,
    expiresAt: new Date(Date.now() + 60 * 60 * 1000), // 1 hour
    createdAt: new Date()
  });

  // Send email with reset link (token in URL, not hash)
  await sendPasswordResetEmail(email, token);

  return { success: true, message: 'If email exists, reset link sent' };
}

// Complete password reset
async function resetPassword(token: string, newPassword: string) {
  // Find valid token
  const resetTokens = await getActivePasswordResetTokens();
  let validToken = null;

  for (const stored of resetTokens) {
    if (await bcrypt.compare(token, stored.tokenHash)) {
      validToken = stored;
      break;
    }
  }

  if (!validToken || validToken.expiresAt < new Date()) {
    throw new Error('Invalid or expired reset token');
  }

  // Validate new password strength
  validatePasswordStrength(newPassword);

  // Update password
  const passwordHash = await bcrypt.hash(newPassword, 12);
  await updateUserPassword(validToken.userId, passwordHash);

  // Invalidate all reset tokens for this user
  await deletePasswordResetTokens(validToken.userId);

  // Optionally invalidate all sessions (force re-login)
  await deleteUserSessions(validToken.userId);

  return { success: true };
}
```

### Rate Limiting

**When to use**: Protect auth endpoints from brute force attacks

**Implementation**: Track failed attempts, implement exponential backoff.

```typescript
// Rate limiter for auth endpoints
const rateLimits = {
  login: { window: 15 * 60, max: 5 },      // 5 attempts per 15 min
  register: { window: 60 * 60, max: 3 },   // 3 signups per hour per IP
  passwordReset: { window: 60 * 60, max: 3 } // 3 resets per hour
};

async function checkRateLimit(type: string, identifier: string) {
  const limit = rateLimits[type];
  const key = `ratelimit:${type}:${identifier}`;

  const attempts = await redis.incr(key);
  if (attempts === 1) {
    await redis.expire(key, limit.window);
  }

  if (attempts > limit.max) {
    const ttl = await redis.ttl(key);
    throw new RateLimitError(`Too many attempts. Try again in ${ttl} seconds`);
  }

  return { remaining: limit.max - attempts };
}

// Login with rate limiting
async function login(email: string, password: string, ip: string) {
  // Rate limit by IP and email separately
  await checkRateLimit('login', ip);
  await checkRateLimit('login', email.toLowerCase());

  const user = await findUserByEmail(email);
  if (!user) {
    // Use constant-time comparison to prevent timing attacks
    await bcrypt.compare(password, '$2b$12$dummy.hash.for.timing');
    throw new AuthError('Invalid credentials');
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    throw new AuthError('Invalid credentials');
  }

  // Clear rate limit on success
  await redis.del(`ratelimit:login:${email.toLowerCase()}`);

  return createSession(user.id);
}
```

## Stack-Specific Implementation

### nextjs-supabase

**Setup**: Supabase Auth handles most complexity. Configure in dashboard and use client.

```bash
# Install Supabase client
npm install @supabase/supabase-js @supabase/ssr
```

```typescript
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options)
          );
        },
      },
    }
  );
}
```

```typescript
// app/auth/signup/route.ts
import { createClient } from '@/lib/supabase/server';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const { email, password } = await request.json();
  const supabase = await createClient();

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      emailRedirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/auth/callback`,
    },
  });

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 400 });
  }

  return NextResponse.json({ user: data.user });
}
```

```typescript
// app/auth/callback/route.ts
import { createClient } from '@/lib/supabase/server';
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const next = searchParams.get('next') ?? '/';

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  return NextResponse.redirect(`${origin}/auth/error`);
}
```

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();

  // Protect dashboard routes
  if (request.nextUrl.pathname.startsWith('/dashboard') && !user) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return response;
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
};
```

**OAuth Configuration**: Configure providers in Supabase Dashboard > Authentication > Providers.

```typescript
// OAuth login
async function signInWithGoogle() {
  const supabase = createBrowserClient();
  await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${window.location.origin}/auth/callback`,
    },
  });
}
```

### remix-railway

**Setup**: Use Lucia Auth for session management with Railway PostgreSQL.

```bash
# Install dependencies
npm install lucia @lucia-auth/adapter-postgresql oslo
npm install -D @types/pg
```

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

## Quality Checklist

- [ ] Passwords hashed with bcrypt (cost 12+) or Argon2id
- [ ] Session tokens stored in httpOnly cookies (not localStorage)
- [ ] CSRF protection enabled for state-changing operations
- [ ] Rate limiting on login (5 attempts/15 min), signup (3/hour), reset (3/hour)
- [ ] Email verification required before full account access
- [ ] Password reset tokens expire within 1 hour
- [ ] Password strength requirements enforced (min 8 chars, complexity)
- [ ] OAuth state parameter validated to prevent CSRF
- [ ] Timing-safe comparison for password verification
- [ ] All sessions invalidated on password change
- [ ] Secure cookie flags set (httpOnly, secure, sameSite)
- [ ] No sensitive data in JWT payload if using JWT

## Integration Points

- **saas-payments**: Link authenticated user to Stripe customer on first payment
- **saas-database**: Store user data, sessions, and auth tokens
- **saas-email**: Send verification and password reset emails
- **saas-api**: Protect API endpoints with session validation middleware

## Anti-Patterns

### JWT in localStorage

**Why it's bad**: Vulnerable to XSS attacks. Any JavaScript on the page can read and exfiltrate the token.

**Instead**: Use httpOnly cookies. The browser automatically sends them and JavaScript cannot access them.

### No Rate Limiting

**Why it's bad**: Allows brute force attacks on passwords and credential stuffing.

**Instead**: Implement rate limiting by IP and email. Use exponential backoff after failures.

### Plain Text Passwords

**Why it's bad**: Database breach exposes all user passwords.

**Instead**: Always hash with bcrypt (cost 12+) or Argon2id. Never store or log plain passwords.

### Email Enumeration

**Why it's bad**: Attackers can determine which emails are registered.

**Instead**: Return same message for both "email sent" and "email not found" on password reset.

### Weak Password Requirements

**Why it's bad**: Users choose easily guessable passwords.

**Instead**: Require minimum 8 characters. Consider checking against breach databases (HaveIBeenPwned API).

### Long-Lived Sessions

**Why it's bad**: Stolen session tokens remain valid indefinitely.

**Instead**: Implement session expiry (7-30 days) with sliding expiration on activity.

## References

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) - security-guidelines
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth) - official-docs
- [Lucia Auth Documentation](https://lucia-auth.com/) - official-docs
- [bcrypt Specification](https://www.usenix.org/legacy/event/usenix99/provos/provos.pdf) - specification
