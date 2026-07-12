# Architecture & Design Rationale

## The Core Decision: Free-Tier Scope Instead of Conditional Access + PIM

This lab was originally designed around Microsoft Entra ID Conditional Access and
Privileged Identity Management (PIM) - the standard enterprise toolset for adaptive
access control and time-bound privilege elevation. Both require premium licensing
(Conditional Access needs P1 minimum; PIM and access reviews need P2), and neither
ships with Entra ID Free.

During build, the P1/P2 trial activation proved unreliable: Microsoft's self-service
trial signup flow intermittently redirects into a separate, unintended tenant, fails
to attach a purchased trial to the correct billing account, or leaves the licence
sitting in a state where it shows as "active" under one admin surface (Microsoft 365
admin center) while remaining invisible to another (Entra ID's own Licenses blade).
This is a known, documented issue, not a one-off configuration mistake.

Rather than ship a portfolio project that depends on licensing that may not reliably
provision for whoever's reviewing it, the scope was redesigned around Azure RBAC (a
separate licensing domain entirely - not gated by Entra ID tier), Entra ID Security
Defaults, and native sign-in log filtering. Every control in this repository's core
scope works identically on any free Azure subscription, with zero dependency on
licence trial behaviour.

**What Conditional Access and PIM would add at enterprise scale**, and how this lab's
design extends toward them, is detailed at the end of this document - the underlying
governance principles are identical; only the tooling differs.

## Policy Design Decisions

### 1. Security Defaults - Baseline MFA Enforcement

Entra ID Free's built-in security baseline: a single tenant-wide toggle enforcing
Microsoft Authenticator-based MFA for all users, blocking legacy authentication
protocols outright, and requiring MFA for privileged actions.

**Trade-off, stated plainly:** Security Defaults is not customisable. It's MFA via
Authenticator only - no SMS, phone call, or FIDO2 key support - and there's no way to
scope it by user group, application, or risk signal. Conditional Access exists
precisely to solve that granularity problem. For a lab (or a small organisation)
without the budget for P1, Security Defaults is a legitimate and effective baseline;
for an enterprise with diverse device fleets and risk-tiered applications, it's a
starting point, not an end state.

### 2. Custom Azure RBAC Roles - Least Privilege by Design

Two roles were defined, each scoped to a specific operational function rather than a
built-in catch-all:

- **VM Operator - No Delete** - grants start, restart, and deallocate actions
  plus read access, and nothing else. Models an operations or helpdesk function that
  needs to manage VM power state without any ability to reconfigure or destroy
  infrastructure.
- **Storage Reader-Only** - grants read access to storage account metadata and blob
  container contents (control-plane Actions and data-plane DataActions
  respectively), with no write, delete, or key-management capability. Models an
  auditor, monitoring tool, or reporting integration.

Both were built from an empty permission set upward - deliberately not derived from
trimming a built-in role like Contributor - to keep the granted surface area
auditable at a glance.

**Verification approach:** the "no delete" boundary was verified structurally, by
inspecting the deployed role definition's JSON directly and confirming no delete or
general write action is present anywhere in the Actions array, rather than
empirically by attempting a live delete against a running resource. This was a
constraint-driven decision - Azure capacity restrictions on B-series VM sizes made a
reliable live test impossible to guarantee during this build - but it's worth stating
plainly: structural verification is arguably the stronger evidence of the two. A
live test proves one specific attempt was blocked; inspecting the role definition
proves the action was never grantable in the first place, which is a permanent
guarantee rather than an observed outcome.

### 3. Sign-In Log Monitoring - Native Filtering Over Log Analytics Export

Entra ID Free includes sign-in and audit logs natively, viewable and filterable
directly in the portal for a 7-day retention window. Exporting those logs to a Log
Analytics workspace for KQL querying - the more scalable, enterprise-pattern
approach - requires P1/P2 licensing tenant-wide, which reintroduces the same
reliability problem described above.

This lab uses the native sign-in log viewer's built-in filtering (by sign-in status,
and separately by client application type) as the primary, licence-independent
method. It surfaces materially the same evidence a KQL query against Log Analytics
would: failed sign-in patterns indicating brute-force or password-spray activity, and
any legacy-protocol usage that would bypass modern MFA entirely.

The equivalent KQL queries are included in monitoring/kql-queries/ as a documented
optional extension for anyone with P1/P2 available, showing the same detection logic
expressed as it would be at enterprise scale - continuous export, ad hoc querying,
and (optionally) automated alerting rather than manual periodic review.

### 4. Manual Quarterly Access Review

Without PIM's automated access review workflow, this lab documents and exercises a
manual equivalent: a scripted export of current role assignments
(scripts/export-rbac-assignments.ps1), reviewed against a fixed checklist
(rbac/access-review-checklist.md) on a quarterly cadence, with findings recorded
before any access is revoked.

The point of documenting this as a formal process, rather than skipping it because
the automated tooling isn't available, is that the governance discipline - did
someone actually check whether this access is still needed - is the thing that
matters. Automation makes that discipline easier to sustain at scale; it doesn't
create the discipline in the first place.

### 5. Break-Glass Emergency Access Account

A dedicated account with permanent (not PIM-eligible, not Conditional-Access-scoped)
Global Administrator access, MFA registered, and credentials held offline. This
exists specifically so that a misconfiguration elsewhere in the tenant's access
controls - including, ironically, in this lab's own Security Defaults enforcement -
can never fully lock out administrative access. Its sign-in activity is a natural
target for the failed-sign-in monitoring described above: this account should sign in
rarely, and any activity from it is worth investigating on sight.

## Tooling Decision: Azure PowerShell Over Azure CLI

Custom role deployment was originally attempted via Azure CLI. On this specific
multi-tenant account, az login and az role definition create repeatedly hit a
reproducible crash in the CLI's Python-based subscription-selector logic
(AttributeError: 'NoneType' object has no attribute 'get'), independent of
credentials or tenant targeting.

Azure PowerShell's Az module - a separate codebase entirely - was substituted, with
explicit tenant and subscription context set via Connect-AzAccount -Tenant and
Set-AzContext -SubscriptionId rather than relying on ambiguous auto-selection. This
resolved the issue cleanly and surfaced a genuinely useful diagnostic along the way: a
breaking-change warning in New-AzRoleDefinition indicating the expected JSON schema
had migrated from a flat Actions/AssignableScopes structure to a nested
Permissions array. The role definition files in rbac/custom-roles/ reflect the
current schema as a direct result of reading and acting on that warning.

## What Conditional Access + PIM Would Add at Enterprise Scale

This lab's design is a foundation, not a ceiling. With P1/P2 licensing available, the
natural extension is:

- **Conditional Access policies**, layered directly on top of Security Defaults'
  baseline: blocking legacy auth with explicit, auditable policy (rather than the
  implicit Security Defaults behaviour), requiring compliant/managed devices for
  access to sensitive applications, and adding location- or risk-based conditional
  verification.
- **PIM eligible role assignments**, replacing the static custom RBAC role
  assignments here with time-bound, justification-required, approval-gated
  activation - the same least-privilege principle this lab implements statically,
  made temporal and auditable per-activation.
- **Automated PIM access reviews**, replacing the manual quarterly process with a
  scheduled workflow that prompts assignees directly and auto-escalates non-response.
- **Log Analytics export as the default**, not an optional extension, feeding a
  persistent Azure Monitor workbook or Sentinel deployment for continuous detection
  and cross-source correlation with resource activity logs and RBAC change history.

None of the work in this lab is thrown away when that licensing becomes available -
the RBAC role definitions, the threat model, and the review process all remain
directly relevant; Conditional Access and PIM add automation and granularity on top
of a design that was already sound.