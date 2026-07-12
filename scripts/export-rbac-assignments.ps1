$outputDir = Join-Path $PSScriptRoot "..\rbac\review-exports"
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$quarter = "{0}-Q{1}" -f (Get-Date).Year, [math]::Ceiling((Get-Date).Month / 3)
$outputFile = Join-Path $outputDir "$quarter-assignments.json"

Write-Host "Exporting current role assignments to $outputFile ..." -ForegroundColor Cyan

Get-AzRoleAssignment | Select-Object DisplayName, SignInName, RoleDefinitionName, Scope, ObjectType |
    ConvertTo-Json -Depth 5 | Out-File -FilePath $outputFile -Encoding utf8

$count = (Get-AzRoleAssignment).Count
Write-Host "Done. $count assignments exported." -ForegroundColor Green