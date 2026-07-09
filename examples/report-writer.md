# Example: report-writer

From a one-line note to a triage-ready report. The skill asks for anything
essential that's missing and never invents impact or data.

## Input

> found IDOR on `/api/v2/invoices/{id}` in the Acme program. Incrementing the
> `id` returns other users' invoices — name, billing address, line items.
> Tested with two of my own accounts (A = attacker, B = victim, invoice 4021).
> IDs are sequential. No special privileges needed.

## Output

> **Title:** IDOR on `/api/v2/invoices/{id}` allows any authenticated user to read other users' invoices
>
> **Summary**
> The invoice endpoint returns any invoice by numeric ID without verifying it
> belongs to the requesting user. Any authenticated user can enumerate `id`
> values and read other customers' invoices, exposing names, billing addresses,
> and line items.
>
> **Steps to Reproduce**
> 1. Register two accounts: User A (attacker) and User B (victim). Note User B's
>    invoice ID — e.g. `4021`.
> 2. Log in as User A and capture the session cookie.
> 3. As User A, request `GET /api/v2/invoices/4021`.
> 4. Observe User B's invoice returned in full.
>
> **Proof of Concept**
> ```http
> GET /api/v2/invoices/4021 HTTP/2
> Host: app.acme.com
> Cookie: session=<User A's session>
> ```
> ```json
> { "id": 4021, "customer": "User B", "billing_address": "[redacted]", ... }
> ```
> (User B is a second account controlled by the reporter — no third-party data accessed.)
>
> **Impact**
> Any authenticated user can read any other user's invoices by incrementing
> `id`. IDs are sequential, so the whole invoice table is enumerable. Exposed
> PII (names, billing addresses, purchase history) enables targeted phishing or
> fraud. No privileges or user interaction required.
>
> **Severity:** High — any logged-in user, mass-enumerable, PII exposure.
> `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N`.
>
> **Remediation**
> Enforce an ownership check: verify the invoice's `customer_id` matches the
> authenticated user before returning it. Return 404 for non-owned IDs.

## What it does with incomplete input

Give it just "found reflected XSS on their search page" and it won't write a
report — it asks for the exact URL/parameter, the payload, the repro steps, and
critically whether the payload *executed* or was only reflected-but-encoded
(which wouldn't be a valid XSS). It reasons from what you give it, never fills
gaps with invention.
