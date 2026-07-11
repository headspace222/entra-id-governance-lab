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

Requires Azure CLI (`az`) installed and logged in (`az login`).

```bash
# Get your subscription ID
az account show --query id -o tsv

# Edit both JSON files in rbac/custom-roles/ - replace <YOUR_SUBSCRIPTION_ID>
# with the value above

# Create the roles
az role definition create --role-definition rbac/custom-roles/vm-operator-no-delete.json
az role definition create --role-definition rbac/custom-roles/storage-reader-only.json

# Confirm they exist
az role definition list --custom-role-only true --query "[].roleName" -o table
```

📸 **Screenshot 4:** Both custom roles listed in Azure Portal (IAM → Roles, filtered to
custom roles), or the CLI output from the list command above.

## Step 4 — Assign a Custom Role to a Test User/Resource Group

```bash
az role assignment create \
  --assignee <test-user-object-id-or-upn> \
  --role "VM Operator - No Delete" \
  --scope /subscriptions/<sub-id>/resourceGroups/<resource-group-name>
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
compressed timeline for the lab, to produce a real findings document.

📸 **Screenshot 11:** Terminal output of `az role assignment list --all`, or the
findings markdown file itself, referenced in the repo.

## Step 9 — Drop Screenshots In and Reference Them

Save into `docs/screenshots/` as `0X-description.png`, then reference in this guide or
the README:

```markdown
![Security defaults enabled](docs/screenshots/01-security-defaults-enabled.png)
```

## Step 10 — Commit and Push

```bash
git add .
git commit -m "Rebuild scope for free tier: Azure RBAC, Security Defaults, sign-in monitoring"
git push
```
