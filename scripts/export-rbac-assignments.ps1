<#
.SYNOPSIS
    Exports current Azure RBAC role assignments for the quarterly access review.

.DESCRIPTION
    Run this locally with the Az PowerShell module installed and connected
    (Connect-AzAccount). Output lands in rbac\review-exports\ - review before
    committing to a public repo, and redact any real object IDs, UPNs, or
    subscription IDs you don't want public.

.EXAMPLE
    .\export-rbac-assignments.ps1
#>

$outputDir = Join-Path $PSScriptRoot "..\rbac\review-exports"
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$quarter = "{0}-Q{1}" -f (Get-Date).Year, [math]::Ceiling((Get-Date).Month / 3)
$outputFile = Join-Path $outputDir "$quarter-assignments.json"

Write-Host "Exporting current role assignments to $outputFile ..." -ForegroundColor Cyan

Get-AzRoleAssignment | Select-Object DisplayName, SignInName, RoleDefinitionName, Scope, ObjectType |
    ConvertTo-Json -Depth 5 | Out-File -FilePath $outputFile -Encoding utf8

$count = (Get-AzRoleAssignment).Count
Write-Host "Done. $count assignments exported." -ForegroundColor Green
Write-Host ""
Write-Host "Next: review against rbac\access-review-checklist.md, then document findings in"
Write-Host "$outputDir\$quarter-findings.md before committing."
