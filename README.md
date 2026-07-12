# Azure RBAC & Identity Baseline Governance Lab

**A production-pattern identity and access governance implementation, built entirely
on a free Azure/Entra ID tenant.**

This lab demonstrates least-privilege access control, baseline identity security, and
sign-in threat detection - the same governance principles a financial services
organisation applies to protect customer data and regulatory posture - using tooling
available on any Azure subscription, free or enterprise.

## Why This Project Exists

Identity compromise, not network intrusion, is the leading cause of breaches in
regulated industries. Financial services firms are held to a specific standard here:
every access grant must be justified, scoped to the minimum required, time-limited
where possible, and auditable after the fact. This lab implements that standard end
to end - role design, deployment, verification, monitoring, and periodic review -
and documents the reasoning behind every decision, not just the steps.

## Scope and a Deliberate Constraint

Microsoft Entra ID Conditional Access and Privileged Identity Management (PIM) -
the tools most enterprises use for adaptive access control and time-bound
elevation - require P1 and P2 licensing respectively. This lab was deliberately
built without them, on Entra ID Free, for two reasons:

1. **Reproducibility.** A portfolio project that depends on a licence trial that may
   not reliably provision (a real, documented issue with Microsoft's trial signup
   flow) is a fragile one. Everything in this repo works on any Azure free
   subscription, every time.
2. **It's a better demonstration of judgement.** Anyone can turn on a licensed
   feature and take a screenshot. Designing an equivalent control set within a hard
   constraint - and explaining the trade-off honestly - is closer to what a real
   infrastructure role actually asks of you.

`docs/architecture.md` documents exactly what Conditional Access and PIM would add at
enterprise scale, and how this lab's design extends cleanly once that licensing is
available.

## What's Included

| Component | Purpose |
|---|---|
| `security-defaults/` | Entra ID Security Defaults configuration and enforcement verification |
| `rbac/custom-roles/` | Two custom Azure RBAC role definitions implementing least privilege, with full design rationale |
| `rbac/access-review-checklist.md` | A documented, repeatable manual access review process |
| `monitoring/sign-in-monitoring.md` | Sign-in threat detection via native log filtering - no premium licensing required |
| `monitoring/kql-queries/` | KQL queries for the Log Analytics / Sentinel-track extension of this same detection logic |
| `scripts/export-rbac-assignments.ps1` | PowerShell automation for the quarterly access review export |
| `docs/architecture.md` | Full design rationale, licensing trade-off analysis, and threat model |
| `docs/setup-guide.md` | Step-by-step reproduction guide with screenshot evidence points |
| `docs/screenshots/` | Evidence of every control actually deployed and verified in a live tenant |

## Threat Model

| Control | Threat Mitigated | Verification Method |
|---|---|---|
| Security Defaults (Authenticator-based MFA) | Credential theft alone is insufficient to authenticate | Live MFA challenge captured during sign-in |
| Custom RBAC roles (least privilege) | Over-permissioned accounts increase blast radius when compromised | Role definition JSON inspected directly - no delete/write action present |
| Break-glass emergency access account | Tenant lockout if the primary admin account is compromised or unavailable | Permanent Global Administrator assignment, credentials held offline |
| Sign-in log filtering (failed attempts) | Brute-force and password-spray patterns | Live filtered query against tenant sign-in data |
| Sign-in log filtering (legacy auth) | Legacy protocols bypass modern MFA entirely | Live filtered query confirming zero legacy-protocol usage |
| Manual quarterly access review | Privilege creep accumulating undetected over time | Scripted export + documented review checklist |

## Prerequisites

- Azure free subscription
- Entra ID Free tier (no P1/P2 required - this is the point)
- Global Administrator or Owner role during initial setup
- Azure PowerShell (Az module) - chosen over Azure CLI after direct comparison; see
  docs/architecture.md for why

## Cost

Every control in this lab's core scope is free: no premium licensing, no paid Azure
resources. The one optional extension - Log Analytics diagnostic export and a
scheduled alert rule - is clearly marked as requiring P1/P2 and carrying a small
per-rule cost, and is not part of the default build.

## Setup Guide

Full reproduction steps, including exactly where each piece of evidence was
captured, are in [docs/setup-guide.md](docs/setup-guide.md).

## Skills Demonstrated

**Identity and access governance**
- Least-privilege role design: scoping custom Azure RBAC roles to the minimum action
  set a defined job function requires, and structurally verifying that boundary
  (inspecting the role definition itself) rather than assuming it from intent
- Break-glass account design and the reasoning for why it must sit outside normal
  access control layers
- Threat modelling access controls against specific attack patterns (credential
  theft, brute-force, legacy-protocol bypass, privilege creep) rather than
  implementing controls generically

**Azure platform engineering**
- Azure RBAC: custom role definitions (JSON schema), scope assignment, and the
  distinction between control-plane Actions and data-plane DataActions
- Azure PowerShell (Az module): role definition and assignment lifecycle,
  subscription/tenant context management, scripted export automation
- Entra ID administration: Security Defaults, sign-in log filtering, user and role
  administration, multi-tenant account navigation
- Diagnosing and resolving a real Az PowerShell breaking-change (the Permissions
  array schema migration) by reading the tool's own warning output and adapting the
  JSON structure accordingly, rather than treating a version mismatch as a blocker

**Engineering judgement under real constraints**
- Recognising when a planned technical approach (Conditional Access, PIM, Log
  Analytics export) is blocked by a genuine external constraint (licensing) versus a
  fixable configuration error, and redesigning scope rather than forcing a workaround
- Choosing structural verification (inspecting a role definition) over empirical
  testing (a live resource action) when infrastructure capacity made the empirical
  path unreliable, and being able to justify why the structural method is, if
  anything, the stronger evidence
- Multi-tenant Azure account troubleshooting: diagnosing tenant/subscription context
  mismatches across the Entra admin center, Microsoft 365 admin center, Azure
  Portal, Azure CLI, and Azure PowerShell - five different surfaces that all needed
  to agree

**Documentation and reproducibility**
- Writing setup documentation precise enough that another engineer (or a future
  version of yourself) can rebuild the entire environment from scratch
- Documenting a design decision honestly, including the parts that didn't go to
  plan, in a way that reads as engineering maturity rather than failure
- Git/GitHub workflow: structured commit history reflecting actual project evolution
  (initial build, licensing constraint discovered, scope redesigned, tooling
  switched, documentation finalised)

## Author

Jane - Cloud & Infrastructure Engineer, AZ-104 candidate.
Part of a broader Azure governance portfolio built for financial services
infrastructure roles.