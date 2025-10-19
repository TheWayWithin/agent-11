# API Documentation Template

Use this template for comprehensive API endpoint documentation.

## Endpoint Template Structure

```markdown
# [Service Name] API

## [HTTP METHOD] /api/[resource]/[action]

[One-line description of what this endpoint does]

### Request

```http
[METHOD] /api/[resource] HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer {token}

{
  "param1": "value1",
  "param2": "value2"
}
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| param1 | string | Yes | Description of parameter |
| param2 | integer | No | Description with default value (default: 0) |

### Response

#### Success (200 OK)
```json
{
  "success": true,
  "data": {
    "id": "res_123456",
    "field1": "value1",
    "field2": "value2"
  }
}
```

#### Error Responses

##### 400 Bad Request
```json
{
  "success": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "Parameter 'param1' is required"
  }
}
```

##### 401 Unauthorized
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token"
  }
}
```

##### 429 Too Many Requests
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "Rate limit exceeded. Try again in 60 seconds."
  }
}
```

### Code Examples

#### JavaScript (fetch)
```javascript
const response = await fetch('https://api.example.com/api/resource', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${accessToken}`
  },
  body: JSON.stringify({
    param1: 'value1',
    param2: 'value2'
  })
});

const data = await response.json();

if (data.success) {
  console.log('Success:', data.data);
} else {
  console.error('Error:', data.error.message);
}
```

#### Python (requests)
```python
import requests

response = requests.post(
    'https://api.example.com/api/resource',
    headers={
        'Authorization': f'Bearer {access_token}'
    },
    json={
        'param1': 'value1',
        'param2': 'value2'
    }
)

data = response.json()

if data['success']:
    print(f"Success: {data['data']}")
else:
    print(f"Error: {data['error']['message']}")
```

#### cURL
```bash
curl -X POST https://api.example.com/api/resource \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {token}" \
  -d '{
    "param1": "value1",
    "param2": "value2"
  }'
```

### Error Codes Reference

| Code | HTTP Status | Description | Action |
|------|-------------|-------------|--------|
| INVALID_INPUT | 400 | Missing or invalid parameters | Check request format |
| UNAUTHORIZED | 401 | Authentication failed | Verify token validity |
| FORBIDDEN | 403 | Insufficient permissions | Check account permissions |
| NOT_FOUND | 404 | Resource doesn't exist | Verify resource ID |
| RATE_LIMITED | 429 | Too many requests | Implement backoff strategy |
| SERVER_ERROR | 500 | Internal error | Retry with exponential backoff |
```

## Authentication Flow Example

For APIs requiring authentication, document the complete flow:

```markdown
# Authentication

## Getting Started

1. **Create API Key**
   - Log in to dashboard
   - Navigate to Settings > API Keys
   - Click "Generate New Key"
   - Save the key securely (shown only once)

2. **Make Authenticated Request**
   ```javascript
   const response = await fetch('https://api.example.com/api/endpoint', {
     headers: {
       'Authorization': `Bearer ${apiKey}`
     }
   });
   ```

3. **Handle Token Expiration**
   - Access tokens expire after 1 hour
   - Use refresh token to get new access token
   - Implement automatic retry with token refresh
```

## Rate Limiting Documentation

```markdown
## Rate Limits

All API endpoints are subject to rate limiting:

| Plan | Requests per minute | Requests per day |
|------|-------------------|------------------|
| Free | 60 | 10,000 |
| Pro | 600 | 100,000 |
| Enterprise | Custom | Custom |

### Rate Limit Headers

Every response includes rate limit information:

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1640000000
```

### Handling Rate Limits

```javascript
async function makeRequestWithRetry(url, options, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    const response = await fetch(url, options);

    if (response.status === 429) {
      const resetTime = response.headers.get('X-RateLimit-Reset');
      const waitTime = (resetTime * 1000) - Date.now();
      await new Promise(resolve => setTimeout(resolve, waitTime));
      continue;
    }

    return response;
  }

  throw new Error('Max retries exceeded');
}
```
```

## Webhook Documentation

```markdown
## Webhooks

Subscribe to events for real-time updates.

### Webhook Endpoints

Configure webhook URLs in Settings > Webhooks.

### Event Types

| Event | Trigger | Payload |
|-------|---------|---------|
| user.created | New user registration | User object |
| payment.succeeded | Successful payment | Payment object |
| subscription.updated | Plan change | Subscription object |

### Webhook Payload

```json
{
  "id": "evt_123456",
  "type": "user.created",
  "created": 1640000000,
  "data": {
    "user": {
      "id": "usr_123456",
      "email": "user@example.com"
    }
  }
}
```

### Verifying Webhooks

```javascript
const crypto = require('crypto');

function verifyWebhook(payload, signature, secret) {
  const hmac = crypto.createHmac('sha256', secret);
  const digest = hmac.update(payload).digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(digest)
  );
}
```

### Webhook Best Practices

1. **Always verify signatures** - Prevent malicious payloads
2. **Respond quickly** - Return 200 within 5 seconds
3. **Process asynchronously** - Queue events for processing
4. **Implement idempotency** - Handle duplicate events gracefully
5. **Retry failed events** - Implement exponential backoff
```

## Pagination Documentation

```markdown
## Pagination

List endpoints support cursor-based pagination.

### Request Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| limit | integer | Items per page (max 100, default 20) |
| cursor | string | Cursor for next page (from previous response) |

### Response Format

```json
{
  "data": [...],
  "pagination": {
    "has_more": true,
    "next_cursor": "crs_abc123"
  }
}
```

### Example: Iterate All Pages

```javascript
async function fetchAllItems(baseUrl) {
  const items = [];
  let cursor = null;

  do {
    const url = cursor
      ? `${baseUrl}?cursor=${cursor}`
      : baseUrl;

    const response = await fetch(url);
    const data = await response.json();

    items.push(...data.data);
    cursor = data.pagination.next_cursor;
  } while (cursor);

  return items;
}
```
```

---

**Reference**: Use this template when documenting any API endpoint. Adapt sections based on endpoint complexity and requirements.
