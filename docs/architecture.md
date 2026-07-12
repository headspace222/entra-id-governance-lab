# Architecture & Design Rationale

## Why This Scope, Not Conditional Access + PIM

Microsoft Entra ID Conditional Access requires at least a P1 license; Privileged
Identity Management (PIM) and access reviews require P2. Neither is included in
Entra ID Free, and free-tier trials for these licenses are notoriously unreliable to
provision on personal/free Azure subscriptions.

Rather than build a portfolio piece that depends on a license that may not reliably
activate, this lab targets identity and access governance using tools available on
every Azure tenant: Azure RBAC, Entra ID Security Defaults, and native log filtering.

**What I'd add with P1/P2 in an enterprise setting:** Conditional Access policies
and PIM eligible role assignments with approval workflows and scheduled access
reviews. The design principles demonstrated here — least privilege, MFA enforcement,
monitoring, and periodic review — are the same principles CA/PIM implement with more
granularity and automation.

## Policy Design Decisions

### 1. Security Defaults
Entra ID Free's baseline security control. Enforces MFA via Microsoft Authenticator
for all users, blocks legacy authentication protocols, and requires admins to
complete MFA for privileged actions.

### 2. Custom Azure RBAC Roles (Least Privilege)
- **VM Operator - No Delete**: can start/restart/deallocate VMs, cannot delete or
  reconfigure them.
- **Storage Reader-Only**: read access to blob containers and metadata, no write or
  delete.

**Verification approach:** the "no delete" boundary is verified structurally, by
inspecting the deployed role definition's Actions list and confirming no `delete` or
general `write` action is present, rather than empirically via a live VM test. Azure
capacity constraints on B-series VM sizes made a reliable live test impractical
during this lab's build, and structural verification is arguably the stronger
evidence anyway — it confirms the boundary can never be exceeded by design.

### 3. Sign-In Log Monitoring
Native Entra ID sign-in log filtering (by Status and Client app) detects failed
sign-in patterns and legacy auth attempts without requiring P1/P2 export licensing.

### 4. Manual Quarterly Access Review
Without PIM's automated access review workflow, this lab documents a manual process
using `scripts/export-rbac-assignments.ps1` on a quarterly cadence.

### 5. Break-Glass Emergency Access Account
A dedicated emergency access account with permanent Global Administrator access,
MFA registered, credentials stored offline.

## What I'd Do Differently at Enterprise Scale

- Layer Conditional Access + PIM on top of this foundation once P1/P2 licensing is in place
- Automate the quarterly access review with a scheduled Azure Automation runbook
- Integrate with a SIEM (e.g. Sentinel) for correlation across logs