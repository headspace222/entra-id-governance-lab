#!/bin/bash
# Exports current Azure RBAC role assignments for the quarterly access review.
# Run locally with Azure CLI installed and logged in (az login).
#
# Usage:
#   ./export-rbac-assignments.sh
#
# Output lands in rbac/review-exports/ - review before committing to a public repo,
# and redact any real object IDs, UPNs, or subscription IDs you don't want public.

set -e

OUTPUT_DIR="$(dirname "$0")/../rbac/review-exports"
mkdir -p "$OUTPUT_DIR"

QUARTER=$(date +"%Y-Q$(( ($(date +%-m)-1)/3+1 ))")
OUTPUT_FILE="$OUTPUT_DIR/${QUARTER}-assignments.json"

echo "Exporting current role assignments to $OUTPUT_FILE ..."
az role assignment list --all --output json > "$OUTPUT_FILE"

echo "Done. $(jq 'length' "$OUTPUT_FILE" 2>/dev/null || echo '(install jq for a count)') assignments exported."
echo ""
echo "Next: review against rbac/access-review-checklist.md, then document findings in"
echo "$OUTPUT_DIR/${QUARTER}-findings.md before committing."
