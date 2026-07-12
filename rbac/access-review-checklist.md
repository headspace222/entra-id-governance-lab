# Manual Quarterly Access Review Checklist

## Process

1. Export current role assignments:
```powershell
   .\scripts\export-rbac-assignments.ps1
```
2. For each assignment, confirm the person still needs it, at least-privilege level.
3. Document findings in review-exports/YYYY-QN-findings.md.
4. Remove or narrow flagged assignments:
```powershell
   Remove-AzRoleAssignment -ObjectId <object-id> -RoleDefinitionName "<role-name>" -Scope <scope>
```
5. Re-export and diff against the previous quarter.

## Review Cadence

| Review | Scope | Reviewer |
|---|---|---|
| Quarterly | Custom role assignments | Self-review |
| Quarterly | Break-glass account sign-in activity | Cross-check against sign-in logs |
| Annually | Built-in role assignments at subscription scope | Full manual audit |