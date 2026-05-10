---
name: saas-auth
description: Implement production-ready authentication for SaaS applications — email/password, OAuth social login (Google, GitHub), session management, JWT handling, password reset, email verification, and magic links. Use when building signup, sign-in, login, signup, password reset, or any auth-related feature.
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

## When NOT to use this skill

This skill covers email/password, OAuth social login, sessions, password reset, and rate limiting for typical SaaS web apps. It is not the right fit for:

- **SSO/SAML enterprise integration.** Use a dedicated identity provider (Okta, Auth0, Azure AD) or a SAML library. The patterns here assume self-managed credentials.
- **OAuth-as-a-provider** (you issuing tokens to third parties). Different shape; build with an OAuth-server library (Hydra, oauth2orize).
- **Passwordless-only architectures** (magic-link only, no password fallback). The patterns here assume password as a default and treat magic links as recovery, not primary.
- **Mobile-native auth** (Sign in with Apple, Google iOS SDK, biometrics). Use the platform SDKs; do not retrofit web patterns onto a native flow.
- **FIDO2 / WebAuthn primary**. Add WebAuthn as a layer if you need it; the patterns here are bcrypt-first and assume password as the recovery primitive.

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

Stack-specific code is held in `references/`. Load only the file matching the project's stack:

- `references/nextjs-supabase.md` for Next.js 14+ with Supabase Auth.
- `references/remix-railway.md` for Remix with Lucia + Railway PostgreSQL.

For other stacks (Express + Passport, Django + django-allauth, Rails + Devise, etc.) apply the patterns above using the framework's idioms: hashing on the way in, httpOnly cookies for sessions, rate limiting on auth endpoints, time-limited reset tokens.

## Exit Criteria

Before declaring this skill's work complete, run each check below and paste the output. "Looks right" is not sufficient. Items marked **gateable** can be wired into `project/gates/` for automated phase-exit checks.

| # | Check | Verification | Pass condition | Gateable |
|---|-------|-------------|----------------|----------|
| 1 | Passwords hashed in code | `grep -rEn "bcrypt\.hash\|argon2.*hash\|Argon2id" --include="*.ts" --include="*.js" --include="*.py" .` | Match in registration and password-reset paths. | yes |
| 2 | No tokens in localStorage | `grep -rEn "localStorage\.setItem.*(token\|session\|jwt\|auth)" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" .` | Zero matches. | yes |
| 3 | Session cookies are httpOnly | `grep -rEn "httpOnly|http_only" --include="*.ts" --include="*.js" --include="*.py" . \| grep -i -E "true\|cookie"` | At least one match in session/cookie configuration. | yes |
| 4 | Rate limiting on login/signup/reset | `grep -rEn "rateLimit\|rate_limit\|ratelimit" --include="*.ts" --include="*.js" --include="*.py" .` | Match attached to login, signup, and password-reset routes. | yes |
| 5 | Password reset tokens expire | Read the password-reset model/schema. | `expires_at` or equivalent column with TTL ≤ 1 hour. | manual |
| 6 | All sessions invalidated on password change | `grep -rEn "deleteUserSessions\|invalidate.*sessions\|sessions.*deleteAll" --include="*.ts" --include="*.js" --include="*.py" .` | Match in password-update handler. | yes |
| 7 | OAuth state parameter validated | `grep -rEn "state.*validate\|verify.*state\|state.*token" --include="*.ts" --include="*.js" --include="*.py" .` (only if OAuth is in use) | Match in OAuth callback handler. | conditional |
| 8 | Constant-time password comparison | Read login handler. | Uses `bcrypt.compare`/`argon2.verify` or library equivalent; never `===` on hashes. | manual |
| 9 | Email enumeration mitigation | Read password-reset handler response. | Returns the same message for both "email sent" and "email not found". | manual |
| 10 | Tests cover failure paths | `npm test -- --testPathPattern=auth` or equivalent. | Tests for invalid credentials, rate limit, expired token, password mismatch. | yes |

If any check fails, do not declare done. Fix and re-run.

## Integration Points

- **saas-payments**: Link authenticated user to Stripe customer on first payment
- **saas-database**: Store user data, sessions, and auth tokens
- **saas-email**: Send verification and password reset emails
- **saas-api**: Protect API endpoints with session validation middleware

## Anti-Patterns (Excuse / Rebuttal)

### Excuse: "I'll put the JWT in localStorage; it's easier and the SPA needs to read it."

**Rebuttal**: localStorage is readable by every script on the page, including third-party scripts and any future XSS bug you have not found yet. One reflected XSS exfiltrates every active session token from the device. Use httpOnly cookies; the browser sends them automatically, JavaScript cannot read them, and the SPA does not actually need to read the token, only act on the session.

### Excuse: "We don't need rate limiting yet; we have no traffic."

**Rebuttal**: You have no legitimate traffic. Bots find sign-in endpoints within hours of going live and run credential-stuffing lists against them whether you have users or not. Add rate limiting before launch, not after the first compromised account: 5 login attempts per 15 minutes per IP and per email, 3 signups per hour per IP, 3 password resets per hour per email.

### Excuse: "We hash the passwords on the way out, that's secure enough."

**Rebuttal**: The only acceptable place to hash is on the way in, before the password ever touches durable storage or logs. Use bcrypt (cost 12 or higher) or Argon2id. "Plain on the way in, hashed in the database" means the plaintext is in your application logs, your error tracker, and your request traces. There is no acceptable variant of "we'll hash it later".

### Excuse: "Telling the user 'no account with that email' is more helpful UX."

**Rebuttal**: It is also a free email-enumeration oracle for attackers. They get to learn which addresses have accounts on your platform and target those specifically with credential-stuffing or phishing. Return the same message for "email sent" and "email not found" on password reset. The legitimate user who mistyped their email gets the same UX as the attacker, and that is fine.

### Excuse: "Strict password rules annoy users; let them pick what they want."

**Rebuttal**: Users pick `password123` and reuse it across sites. The minimum acceptable rules are: 8 characters, not in the top-1000 list, ideally checked against HaveIBeenPwned. These do not annoy real users; they stop one shape of breach. Ship them on day one.

### Excuse: "Long sessions are convenient; users hate logging in repeatedly."

**Rebuttal**: Convenient sessions are also persistent attack surface; a stolen cookie that lasts forever lasts forever. Set a 7 to 30 day cap with sliding expiration on activity, and invalidate all sessions on password change. Users do not notice sliding expiration; they do notice their account being taken over.

## References

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html) - security-guidelines
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth) - official-docs
- [Lucia Auth Documentation](https://lucia-auth.com/) - official-docs
- [bcrypt Specification](https://www.usenix.org/legacy/event/usenix99/provos/provos.pdf) - specification
