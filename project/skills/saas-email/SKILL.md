---
name: saas-email
version: 1.0.0
category: communication
triggers:
  - email
  - transactional email
  - email template
  - send email
  - email notification
  - resend
  - sendgrid
  - postmark
  - email queue
  - email delivery
specialist: "@developer"
stack_aware: true
complexity: beginner
estimated_tokens: 3200
dependencies: []
---

# SaaS Transactional Email

## Capability

Implement reliable transactional email delivery for SaaS applications including templating, queuing, delivery tracking, and provider abstraction. Covers common email types: welcome, verification, password reset, notifications, and invoices.

## Use Cases

- Welcome and onboarding emails
- Email verification and password reset
- Notification emails (activity alerts, reminders)
- Invoice and receipt emails
- Team invitation emails
- Digest and summary emails

## Patterns

### Email Service Abstraction

**When to use**: Decouple email sending from specific provider (Resend, SendGrid, etc.)

**Implementation**: Create provider-agnostic interface with consistent API.

```typescript
// Email service interface
interface EmailService {
  send(options: SendEmailOptions): Promise<EmailResult>;
  sendBatch(emails: SendEmailOptions[]): Promise<EmailResult[]>;
}

interface SendEmailOptions {
  to: string | string[];
  subject: string;
  template: string;
  data: Record<string, unknown>;
  replyTo?: string;
  tags?: string[];
}

// Resend implementation
class ResendEmailService implements EmailService {
  private client: Resend;

  constructor(apiKey: string) {
    this.client = new Resend(apiKey);
  }

  async send(options: SendEmailOptions): Promise<EmailResult> {
    const html = await renderTemplate(options.template, options.data);

    const result = await this.client.emails.send({
      from: 'Your App <noreply@yourapp.com>',
      to: Array.isArray(options.to) ? options.to : [options.to],
      subject: options.subject,
      html,
      reply_to: options.replyTo,
      tags: options.tags?.map(t => ({ name: t, value: 'true' }))
    });

    return {
      id: result.id,
      success: true
    };
  }

  async sendBatch(emails: SendEmailOptions[]): Promise<EmailResult[]> {
    return Promise.all(emails.map(e => this.send(e)));
  }
}

// Usage
const emailService = new ResendEmailService(process.env.RESEND_API_KEY);

await emailService.send({
  to: 'user@example.com',
  subject: 'Welcome to Our App',
  template: 'welcome',
  data: { userName: 'John', appName: 'MyApp' }
});
```

### React Email Templates

**When to use**: Build maintainable, styled email templates with React

**Implementation**: Use React Email for component-based email templates.

```tsx
// emails/welcome.tsx
import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text
} from '@react-email/components';

interface WelcomeEmailProps {
  userName: string;
  appName: string;
  dashboardUrl: string;
}

export default function WelcomeEmail({
  userName,
  appName,
  dashboardUrl
}: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Welcome to {appName}!</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>Welcome, {userName}!</Heading>
          <Text style={text}>
            Thanks for signing up for {appName}. We're excited to have you!
          </Text>
          <Section style={buttonContainer}>
            <Button style={button} href={dashboardUrl}>
              Go to Dashboard
            </Button>
          </Section>
          <Text style={footer}>
            If you didn't create this account, please ignore this email.
          </Text>
        </Container>
      </Body>
    </Html>
  );
}

const main = { backgroundColor: '#f6f9fc', padding: '40px 0' };
const container = { backgroundColor: '#ffffff', padding: '40px', borderRadius: '8px' };
const h1 = { color: '#1a1a1a', fontSize: '24px' };
const text = { color: '#4a4a4a', fontSize: '16px', lineHeight: '24px' };
const buttonContainer = { textAlign: 'center' as const, margin: '32px 0' };
const button = { backgroundColor: '#5469d4', color: '#fff', padding: '12px 24px', borderRadius: '6px' };
const footer = { color: '#8898aa', fontSize: '12px' };

// Render template
import { render } from '@react-email/render';
import WelcomeEmail from './emails/welcome';

async function renderTemplate(template: string, data: Record<string, unknown>) {
  const templates = {
    welcome: WelcomeEmail,
    verification: VerificationEmail,
    passwordReset: PasswordResetEmail,
    invitation: InvitationEmail
  };

  const Component = templates[template];
  return render(<Component {...data} />);
}
```

### Email Queue with Retries

**When to use**: Reliable email delivery with failure handling

**Implementation**: Queue emails for async processing with retry logic.

```typescript
// Email job processor
import { Queue, Worker } from 'bullmq';

const emailQueue = new Queue('emails', {
  connection: redis,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000 // 1s, 2s, 4s
    },
    removeOnComplete: 100,
    removeOnFail: 1000
  }
});

// Add email to queue
async function queueEmail(options: SendEmailOptions) {
  await emailQueue.add('send', options, {
    priority: getEmailPriority(options.template)
  });
}

// Email priorities
function getEmailPriority(template: string): number {
  const priorities = {
    passwordReset: 1,   // Highest
    verification: 2,
    invitation: 3,
    notification: 5,
    digest: 10          // Lowest
  };
  return priorities[template] ?? 5;
}

// Worker to process queue
const emailWorker = new Worker('emails', async (job) => {
  const { to, subject, template, data } = job.data;

  try {
    const result = await emailService.send({ to, subject, template, data });

    // Log success
    await logEmailEvent(result.id, 'sent', { to, template });

    return result;
  } catch (error) {
    // Log failure
    await logEmailEvent(null, 'failed', { to, template, error: error.message });
    throw error; // Trigger retry
  }
}, { connection: redis });

// Handle final failure
emailWorker.on('failed', async (job, error) => {
  if (job.attemptsMade >= job.opts.attempts) {
    await alertOnEmailFailure(job.data, error);
  }
});
```

### Common Email Templates

**When to use**: Standard SaaS email types

```typescript
// Email sending helpers
const emails = {
  async sendWelcome(user: User) {
    await queueEmail({
      to: user.email,
      subject: 'Welcome to MyApp!',
      template: 'welcome',
      data: {
        userName: user.name,
        appName: 'MyApp',
        dashboardUrl: `${APP_URL}/dashboard`
      }
    });
  },

  async sendVerification(user: User, token: string) {
    await queueEmail({
      to: user.email,
      subject: 'Verify your email',
      template: 'verification',
      data: {
        userName: user.name,
        verifyUrl: `${APP_URL}/verify?token=${token}`
      }
    });
  },

  async sendPasswordReset(user: User, token: string) {
    await queueEmail({
      to: user.email,
      subject: 'Reset your password',
      template: 'passwordReset',
      data: {
        userName: user.name,
        resetUrl: `${APP_URL}/reset-password?token=${token}`,
        expiresIn: '1 hour'
      }
    });
  },

  async sendInvitation(invitation: Invitation, inviter: User) {
    await queueEmail({
      to: invitation.email,
      subject: `${inviter.name} invited you to join ${invitation.orgName}`,
      template: 'invitation',
      data: {
        inviterName: inviter.name,
        orgName: invitation.orgName,
        acceptUrl: `${APP_URL}/accept-invite?token=${invitation.token}`
      }
    });
  }
};
```

## Stack Implementations

### {{stack.services.email}} Integration

**Resend (Recommended)**:
```typescript
import { Resend } from 'resend';
const resend = new Resend(process.env.RESEND_API_KEY);
```

**SendGrid**:
```typescript
import sgMail from '@sendgrid/mail';
sgMail.setApiKey(process.env.SENDGRID_API_KEY);
```

**Postmark**:
```typescript
import { ServerClient } from 'postmark';
const postmark = new ServerClient(process.env.POSTMARK_API_KEY);
```

## Quality Checklist

- [ ] Email service abstracted from provider
- [ ] All emails queued for reliability
- [ ] Retry logic with exponential backoff
- [ ] Email delivery logged for debugging
- [ ] Unsubscribe links in marketing emails
- [ ] Reply-to configured appropriately
- [ ] Templates tested across email clients
- [ ] Plain text fallback for HTML emails
- [ ] Rate limiting on email sending
- [ ] Failed email alerts configured

## Anti-Patterns

### Sending Email Synchronously in Request
```typescript
// WRONG: Blocks request, no retry on failure
app.post('/signup', async (req, res) => {
  await createUser(req.body);
  await emailService.send({ ... }); // Blocks!
  res.json({ success: true });
});

// RIGHT: Queue and return immediately
app.post('/signup', async (req, res) => {
  const user = await createUser(req.body);
  await queueEmail({ ... }); // Non-blocking
  res.json({ success: true });
});
```

### Hardcoding Email Content
```typescript
// WRONG: HTML in code, hard to maintain
const html = `<h1>Welcome ${name}</h1><p>Thanks for signing up...</p>`;

// RIGHT: Use template system
const html = await renderTemplate('welcome', { name });
```
