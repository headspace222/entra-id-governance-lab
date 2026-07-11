# Manual Quarterly Access Review Checklist

Without PIM's automated access review workflow (P2-only), this process substitutes a
documented manual review on a quarterly cadence.

## Process

1. **Export current role assignments** (see `scripts/export-rbac-assignments.sh`):
   ```bash
   az role assignment list --all --output json > review-exports/YYYY-QN-assignments.json
   ```
2. **For each assignment, confirm:**
   - [ ] Is this person/service still active in the organization?
   - [ ] Does their current role/project still require this access level?
   - [ ] Is this the least-privilege role available for their need, or could it be
         narrowed (e.g. from Contributor to a custom scoped role)?
   - [ ] Was this access granted with an expiration or business justification on
         record? If not, document one now.
3. **Document findings** in `review-exports/YYYY-QN-findings.md`:
   - Assignments confirmed as still needed
   - Assignments flagged for removal or narrowing, with owner and target date
   - Any assignments with no clear justification (escalate for follow-up)
4. **Remove or narrow flagged assignments:**
   ```bash
   az role assignment delete --assignee <object-id> --role "<role-name>" --scope <scope>
   ```
5. **Re-export and diff** against the previous quarter's export to confirm changes
   were applied.

## Review Cadence

| Review | Scope | Reviewer |
|---|---|---|
| Quarterly | All custom role assignments (VM Operator, Storage Reader) | Self-review, escalate ambiguous cases |
| Quarterly | Break-glass account sign-in activity | Cross-check against KQL alert history |
| Annually | Built-in role assignments (Owner, Contributor) at subscription scope | Full manual audit — these are the highest-impact assignments in the tenant |

## Why Document This Manually Instead of Skipping It

A recruiter or interviewer reviewing this repo should see that the *discipline* of
periodic access review doesn't require premium tooling to exist — PIM automates and
enforces a workflow that, done manually, still produces the same governance outcome.
Being able to explain this trade-off (automation vs. manual process, and when each is
appropriate) is itself a useful thing to demonstrate.
