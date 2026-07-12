# Entra ID Security Defaults

## What It Is

Security Defaults is Entra ID Free's built-in identity security baseline: a single
tenant-wide control (not a customisable policy set) that enforces four behaviours
simultaneously:

1. Every user must register for and authenticate via Microsoft Authenticator
2. Legacy authentication protocols are blocked tenant-wide, with no exceptions
3. Administrators must complete an MFA challenge before performing privileged actions
4. Users must complete an MFA challenge when a sign-in is flagged as risky

It ships enabled by default on tenants created after October 2019, and remains the
only MFA enforcement mechanism available without Conditional Access (P1 licensing).

## Configuration

1. Entra ID -> Overview -> Properties
2. Manage security defaults
3. Confirm or set Security defaults to Enabled
4. Save

There is a 24-hour grace period before enforcement becomes mandatory after enabling.

## Why This Control, Specifically

Credential-only authentication is the single most common initial access vector in
identity-based breaches. Security Defaults closes that gap with zero licensing cost
and zero configuration complexity - which is precisely its strength and its
limitation simultaneously.

**The honest limitation:** Security Defaults is not a policy engine. It cannot be
scoped by user group, application sensitivity, device compliance state, network
location, or calculated risk level - it is uniformly on or uniformly off, tenant-wide.
For an enterprise with regulatory obligations spanning multiple business lines,
Security Defaults is the floor, not the ceiling - Conditional Access (P1+) exists
specifically to add that missing granularity.

Security Defaults and Conditional Access are mutually exclusive at the platform
level: enabling any Conditional Access policy automatically disables Security
Defaults for the tenant.

## Verifying Enforcement

1. Open an incognito/private browser session
2. Sign in as any tenant user at myaccount.microsoft.com or portal.azure.com
3. If Authenticator isn't yet registered, you'll be interrupted with a registration
   prompt
4. If already registered, you'll see a live MFA challenge - an "Approve sign in
   request" prompt

**Evidence captured for this lab:** docs/screenshots/02-mfa-enforcement.png shows
the live Authenticator approval challenge, captured during an actual sign-in attempt
against the tenant used throughout this project.