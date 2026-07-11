# Architecture & Design Rationale

## Why This Scope, Not Conditional Access + PIM

Microsoft Entra ID Conditional Access requires at least a P1 license; Privileged
Identity Management (PIM) and access reviews require P2. Neither is included in
Entra ID Free, and free-tier trials for these licenses are notoriously unreliable to
provision on personal/free Azure subscriptions (tenant mismatches, trial-per-tenant
limits, and signup flows that redirect into an entirely separate tenant are all
common, documented issues).

Rather than build a portfolio piece that depends on a license that may not reliably
activate, this lab targets identity and access governance using tools available on
every Azure tenant: Azure RBAC (a separate licensing domain from Entra ID premium
tiers), Entra ID Security Defaults, and Azure Monitor/Log Analytics.

**What I'd add with P1/P2 in an enterprise setting:** Conditional Access policies
(legacy auth blocking, compliant-device requirements, location-based risk) and PIM
(eligible role assignments, approval workflows, scheduled access reviews). The design
principles demonstrated here — least privilege, MFA enforcement, monitoring, and
periodic review — are the same principles CA/PIM implement with more granularity and
automation. This is a worthwhile point to raise directly in interview: the underlying
governance thinking transfers, even though the tooling here is the free-tier
equivalent.

## Policy Design Decisions

### 1. Security Defaults
Entra ID Free's baseline security control. Enforces MFA (via Microsoft Authenticator
only) for all users, blocks legacy authentication protocols, and requires admins to
complete MFA for privileged actions. It's a single on/off toggle rather than a
customizable policy — the trade-off for zero cost is zero granularity. Documented here
as the starting security posture before any custom controls are layered on.

### 2. Custom Azure RBAC Roles (Least Privilege)
Rather than assigning built-in roles like Contributor (broad write access across most
resource types) or Owner (full control including access management), this lab defines
narrow custom roles scoped to specific operational needs:

- **VM Operator - No Delete**: can start/restart/deallocate VMs, cannot delete or
  reconfigure them. Models a helpdesk/operations team that needs to manage VM power
  state but shouldn't be able to destroy infrastructure.
- **Storage Reader-Only**: read access to blob containers and metadata, no write or
  delete. Models an auditor or reporting tool that needs visibility without write
  access.

This is a direct, practical demonstration of least privilege — the same principle PIM
enforces via time-bound elevation, just applied statically here since PIM tooling
isn't available on Free tier.

### 3. Sign-In Log Monitoring via KQL
Entra ID Free includes sign-in and audit logs (this is one of the few premium-adjacent
features actually included free). Streaming these into a Log Analytics workspace and
querying with KQL recreates a meaningful slice of what Conditional Access + Identity
Protection would otherwise automate: detecting failed sign-in patterns and legacy auth
attempts that indicate brute-force or password-spray activity.

### 4. Manual Quarterly Access Review
Without PIM's automated access review workflow, this lab documents a manual process:
export current RBAC role assignments via Azure CLI on a quarterly cadence, review
against a checklist of "does this person still need this access," and document
findings. Not automated, but demonstrates the same governance discipline.

### 5. Break-Glass Emergency Access Account
Still relevant without Conditional Access: a dedicated emergency access account with
permanent Owner/Global Administrator access, MFA registered, credentials stored
offline, and its sign-in activity specifically monitored via the KQL queries in this
repo (any sign-in from this account should be rare and worth investigating).

## What I'd Do Differently at Enterprise Scale

- Layer Conditional Access + PIM on top of this foundation once P1/P2 licensing is in
  place — this lab's RBAC and monitoring work stays relevant even after CA/PIM are added
- Automate the quarterly access review with a scheduled Azure Automation runbook rather
  than a manual CLI export
- Move KQL queries into saved Azure Monitor workbooks for a persistent dashboard rather
  than ad hoc queries
- Integrate with a SIEM (e.g. Sentinel) for correlation across sign-in logs, resource
  activity logs, and RBAC changes
