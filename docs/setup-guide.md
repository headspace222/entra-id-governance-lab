# Setup Guide

Everything here works on a genuinely free Azure/Entra ID subscription - no P1/P2
trial required.

## Step 1 — Enable Security Defaults

See `security-defaults/security-defaults-notes.md` for full detail.

Screenshot 1: Security defaults toggle enabled (Entra ID -> Properties).
Screenshot 2: MFA enforcement challenge screen.

## Step 2 — Create a Break-Glass Account

1. Entra ID -> Users -> New user -> e.g. breakglass-emergency-admin
2. Assign Global Administrator directly (permanent)
3. Register MFA on this account too, store credentials offline

Screenshot 3: Break-glass account with Global Administrator role assignment visible.

## Step 3 — Deploy the Custom RBAC Roles

Uses Azure PowerShell (the Az module).

```powershell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount -Tenant "<your-tenant-id>"
Set-AzContext -SubscriptionId "<your-subscription-id>"
Get-AzContext

cd C:\entra-id-governance-lab
New-AzRoleDefinition -InputFile "rbac\custom-roles\vm-operator-no-delete.json"
New-AzRoleDefinition -InputFile "rbac\custom-roles\storage-reader-only.json"
Get-AzRoleDefinition -Custom | Select-Object Name, Id
```

Screenshot 4: Both custom roles listed.

## Step 4 — Assign a Custom Role

```powershell
New-AzRoleAssignment -ObjectId "<object-id>" -RoleDefinitionName "VM Operator - No Delete" -Scope "/subscriptions/<sub-id>/resourceGroups/<rg-name>"
```

Screenshot 5: Role assignment visible in IAM.
Screenshot 6: The custom role's Permissions/JSON view showing no delete action.

## Step 5 — Sign-In Monitoring

See monitoring/sign-in-monitoring.md.

Screenshot 7: Sign-in logs filtered by Status: Failure.
Screenshot 8: Sign-in logs filtered by legacy auth client types.

## Step 6 — Run a Quarterly Access Review

```powershell
.\scripts\export-rbac-assignments.ps1
```

Screenshot 9: PowerShell output of the export, or the findings markdown file.

## Step 7 — Drop Screenshots In

Save into docs/screenshots/ as 0X-description.png.

## Step 8 — Commit and Push

```powershell
git add .
git commit -m "Rebuild scope for free tier: Azure RBAC, Security Defaults, sign-in monitoring"
git push
```