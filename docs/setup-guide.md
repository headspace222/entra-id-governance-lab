# Setup Guide

This guide reproduces the entire lab from a blank Azure/Entra ID free subscription.
Every step below was executed against a live tenant during this project's build -
this is a record of what actually worked, including the tooling switch documented in
docs/architecture.md, not an idealised version of events.

**Estimated time:** 60-90 minutes for a first pass, most of it Azure portal
navigation rather than active work.

## Step 1 - Enable Security Defaults

Full detail: security-defaults/security-defaults-notes.md.

1. Entra ID -> Overview -> Properties
2. Manage security defaults -> set to Enabled -> Save

Note: many tenants created after October 2019 have this enabled by default - check
before assuming a change is needed.

**Evidence to capture:**
- 01-security-defaults-enabled.png - the Properties page showing the toggle state
- 02-mfa-enforcement.png - the MFA challenge screen triggered during a live sign-in
  (open an incognito window, sign in as any user, and capture the Authenticator
  approval prompt)

## Step 2 - Create a Break-Glass Account

1. Entra ID -> Users -> New user -> name it clearly
   (e.g. breakglass-emergency-admin)
2. Assigned roles -> Add assignments -> Global Administrator, assigned
   permanently - not via any eligibility or time-bound mechanism
3. Register MFA on this account; store its credentials in a password manager, kept
   separate from day-to-day admin credentials

**Evidence to capture:**
- 03-breakglass-account.png - the account's Assigned roles page

## Step 3 - Deploy the Custom RBAC Roles

This lab uses Azure PowerShell (the Az module), not Azure CLI - see
docs/architecture.md for why, if you hit the same CLI issue.

```powershell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount -Tenant "<your-tenant-id>"
Set-AzContext -SubscriptionId "<your-subscription-id>"
Get-AzContext
```

Edit both files in rbac/custom-roles/, replacing <YOUR_SUBSCRIPTION_ID> with the
value confirmed above, then:

```powershell
cd C:\entra-id-governance-lab
New-AzRoleDefinition -InputFile "rbac\custom-roles\vm-operator-no-delete.json"
New-AzRoleDefinition -InputFile "rbac\custom-roles\storage-reader-only.json"
Get-AzRoleDefinition -Custom | Select-Object Name, Id
```

**Schema note:** these JSON files use the Permissions array format, required by
current Az.Resources module versions.

**Evidence to capture:**
- 04-custom-roles-list.png - the Get-AzRoleDefinition -Custom output, or the
  equivalent Portal view

## Step 4 - Assign a Role and Verify the Boundary

```powershell
New-AzResourceGroup -Name "rg-governance-lab" -Location "<your-region>"
Get-AzADUser -UserPrincipalName "<upn>" | Select-Object DisplayName, Id
New-AzRoleAssignment -ObjectId "<object-id>" -RoleDefinitionName "VM Operator - No Delete" -Scope "/subscriptions/<sub-id>/resourceGroups/rg-governance-lab"
```

**Evidence to capture:**
- 05-role-assignment-check-access.png - IAM Role assignments showing the assignment
- 06-vm-operator-role-permissions.png - the custom role's Permissions/JSON tab,
  showing no delete or write action present - a structural boundary check chosen
  deliberately over a live resource test.

## Step 5 - Sign-In Monitoring

Full detail: monitoring/sign-in-monitoring.md.

1. Entra ID -> Monitoring & health -> Sign-in logs
2. Add filter -> Status -> Failure

**Evidence to capture:**
- 07-failed-signins-filtered.png

3. Clear that filter, then Add filter -> Client app -> Legacy Authentication Clients

**Evidence to capture:**
- 08-legacy-auth-filter.png - "No sign-ins found" is the correct outcome here.

**Optional (P1/P2 required):** monitoring/kql-queries/ documents the Log Analytics
equivalent.

## Step 6 - Run a Quarterly Access Review

```powershell
.\scripts\export-rbac-assignments.ps1
```

**Evidence to capture:**
- 09-access-review-export.png

## Step 7 - Finalise and Push

```powershell
cd C:\entra-id-governance-lab
git add -A
git commit -m "Complete lab build: RBAC roles deployed, monitoring verified, evidence captured"
git push
```

## A Note on What Went Wrong Along the Way

This build did not go in a straight line, and that's worth being transparent about
rather than editing out. The original design targeted Conditional Access and PIM;
licensing trial provisioning proved unreliable enough to force a scope redesign
around Azure RBAC and native log filtering instead. Azure CLI hit a reproducible bug
on this account's multi-tenant configuration, resolved by switching to Azure
PowerShell. A live VM test for the RBAC boundary was abandoned after repeated Azure
capacity restrictions on B-series sizes, replaced with structural role-definition
verification. Every one of these was a real constraint encountered during a genuine
build, not a scripted scenario - and the resolution in each case is documented in
docs/architecture.md alongside the reasoning, because that reasoning is the actual
skill being demonstrated here.