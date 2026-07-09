# Report Template

Fill each section. Keep it tight — a triager should reproduce the bug in under
two minutes. A worked example (IDOR) follows the blank template.

---

## Blank Template

**Title:** `<Vulnerability type> on <asset> allows <concrete impact>`

### Summary
<2–3 sentences: what the bug is, where it lives, and why it matters. No preamble.>

### Steps to Reproduce
1. <Start from a clean, described state — e.g. "Log in as User A (attacker)">
2. <Exact action, including the exact request if relevant>
3. <Next action>
4. <Observe the result that proves the bug>

### Proof of Concept
```http
<The exact request that triggers the bug — method, path, headers, body>
```
```
<The relevant part of the response that proves it — redact real victim data>
```

### Impact
<Concrete, realistic consequences. What can an attacker actually do, at what
scale, with what preconditions? Plain language first, then CVSS vector if the
program uses one.>

### Severity
<Suggested rating + one sentence of reasoning tied to the signals above.>

### Remediation
<The specific fix for this bug class, applied to what was observed.>

---

## Worked Example — IDOR

**Title:** IDOR on `/api/v2/invoices/{id}` allows any authenticated user to read other users' invoices

### Summary
The invoice endpoint returns any invoice by numeric ID without checking that the
invoice belongs to the requesting user. Any authenticated user can enumerate
`id` values and read other customers' invoices, which include name, billing
address, and line items.

### Steps to Reproduce
1. Register two accounts: User A (attacker) and User B (victim). Note User B's
   invoice ID from their dashboard — e.g. `4021`.
2. Log in as User A and capture the session cookie.
3. As User A, send:
   ```http
   GET /api/v2/invoices/4021 HTTP/2
   Host: app.example.com
   Cookie: session=<User A's session>
   ```
4. Observe that User B's invoice is returned in full, despite belonging to a
   different account.

### Proof of Concept
```http
GET /api/v2/invoices/4021 HTTP/2
Host: app.example.com
Cookie: session=<User A's session>
```
```json
{ "id": 4021, "customer": "User B", "billing_address": "[redacted]",
  "total": "$482.10", "items": [ ... ] }
```
(User B is a second account controlled by the reporter — no third-party data was accessed.)

### Impact
Any authenticated user can read any other user's invoices by incrementing the
`id`. Invoice IDs are sequential, so the entire invoice table is enumerable.
Exposed data includes customer names, billing addresses, and purchase history —
PII that could enable targeted phishing or fraud. No special privileges or user
interaction required.

### Severity
High. Unauthenticated-adjacent (any logged-in user), mass-enumerable, exposes
PII for all customers. CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N.

### Remediation
Enforce an ownership check on the invoice lookup: verify the invoice's
`customer_id` matches the authenticated user's ID before returning it. Return
404 (not 403) for non-owned IDs to avoid confirming their existence.
