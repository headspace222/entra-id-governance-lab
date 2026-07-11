# Setup Guide

Everything here works on a genuinely free Azure/Entra ID subscription - no P1/P2
trial required.

## Step 1 — Enable Security Defaults

See `security-defaults/security-defaults-notes.md` for full detail.

📸 **Screenshot 1:** Security defaults toggle enabled (Entra ID → Properties).
📸 **Screenshot 2:** MFA registration prompt for a test user after enforcement begins.

## Step 2 — Create a Break-Glass Account

1. Entra ID → **Users** → **New user** → e.g. `breakglass-emergency-admin`
2. Assign **Global Administrator** directly (permanent, not conditional on anything)
3. Register MFA on this account too, but store its credentials offline/securely
4. Note its Object ID - useful for the KQL queries if you want to explicitly track its
   sign-in activity separately

📸 **Screenshot 3:** Break-glass account with Global Administrator role assignment visible.

## Step 3 — Deploy the Custom RBAC Roles

Uses Azure PowerShell (the `Az` module) rather than Azure CLI - more reliable across
multi-tenant accounts, and what this lab was actually built and tested with.

```powershell
# Install the Az module if not already present
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

# Connect - if your account spans multiple tenants, target the correct one explicitly
Connect-AzAccount -Tenant "<your-tenant-id>"

# Set and confirm the active subscription context
Set-AzContext -SubscriptionId "<your-subscription-id>"
Get-AzContext

# Edit both JSON files in rbac/custom-roles/ - replace <YOUR_SUBSCRIPTION_ID>
# with your actual subscription ID (must match what Get-AzContext shows above)

cd C:\entra-id-governance-lab
New-AzRoleDefinition -InputFile "rbac\custom-roles\vm-operator-no-delete.json"
New-AzRoleDefinition -InputFile "rbac\custom-roles\storage-reader-only.json"

# Confirm they exist
Get-AzRoleDefinition -Custom | Select-Object Name, Id
```

**Schema note:** the JSON files in this repo use the `Permissions` array format
(`{"Permissions": [{"Actions": [...], ...}]}`), not the older flattened format
(`{"Actions": [...]}` at the root). Az PowerShell versions from roughly 14.x onward
require the nested format - if `New-AzRoleDefinition` throws `Invalid value for
Permissions` or a null-reference error, check which format your file is in against
the examples in `rbac/custom-roles/`.

📸 **Screenshot 4:** Both custom roles listed via `Get-AzRoleDefinition -Custom`, or
in Azure Portal under Subscription → Access control (IAM) → Roles, filtered to
custom roles.

## Step 4 — Assign a Custom Role to a Test User/Resource Group

```powershell
New-AzRoleAssignment -SignInName "<test-user-upn>" -RoleDefinitionName "VM Operator - No Delete" -Scope "/subscriptions/<sub-id>/resourceGroups/<resource-group-name>"
```

📸 **Screenshot 5:** Role assignment visible in Azure Portal IAM blade for the resource
group, showing the custom role and assigned user.
📸 **Screenshot 6:** The assigned user successfully starting/restarting a VM, and (to
prove the "no delete" boundary works) a screenshot of a denied delete attempt.

## Step 5 — Stream Sign-In Logs to Log Analytics

See `monitoring/alert-rule-config.md` Step "Prerequisite" for the diagnostic setting
configuration.

📸 **Screenshot 7:** Diagnostic setting showing SignInLogs → Log Analytics workspace.

## Step 6 — Run the KQL Queries

1. Log Analytics workspace → **Logs**
2. Paste and run `monitoring/kql-queries/failed-signins.kql`
3. Paste and run `monitoring/kql-queries/legacy-auth-attempts.kql`

📸 **Screenshot 8:** Query results for failed sign-ins (even if empty/low-volume in a
lab tenant - the working query is the evidence).
📸 **Screenshot 9:** Query results for legacy auth attempts.

## Step 7 — (Optional) Set Up the Alert Rule

See `monitoring/alert-rule-config.md` for full steps and a cost note - this step has a
small non-zero cost, unlike everything else in this lab.

📸 **Screenshot 10 (optional):** Alert rule configuration.

## Step 8 — Run a Quarterly Access Review

Follow `rbac/access-review-checklist.md` end to end at least once, even on a
compressed timeline for the lab, to produce a real findings document. Use
`scripts/export-rbac-assignments.ps1` to generate the export referenced in that
checklist:

```powershell
.\scripts\export-rbac-assignments.ps1
```

📸 **Screenshot 11:** PowerShell output of `Get-AzRoleAssignment`, or the findings
markdown file itself, referenced in the repo.

## Step 9 — Drop Screenshots In and Reference Them

Save into `docs/screenshots/` as `0X-description.png`, then reference in this guide or
the README:

```markdown
![Security defaults enabled](docs/screenshots/01-security-defaults-enabled.png)
```

## Step 10 — Commit and Push

```powershell
git add .
git commit -m "Rebuild scope for free tier: Azure RBAC, Security Defaults, sign-in monitoring"
git push
```
