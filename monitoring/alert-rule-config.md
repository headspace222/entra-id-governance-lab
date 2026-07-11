# Azure Monitor Alert Rule Configuration

## Prerequisite: Stream Sign-In Logs to Log Analytics

Sign-in logs don't flow to Log Analytics by default - this must be configured once:

1. **Entra ID** → **Monitoring** → **Diagnostic settings** → **+ Add diagnostic setting**
2. Name it (e.g. `signin-logs-to-law`)
3. Check **SignInLogs** under Logs
4. Destination: **Send to Log Analytics workspace** → select or create a workspace
5. Save

📸 **Screenshot:** Diagnostic setting configuration showing SignInLogs → Log Analytics destination.

## Alert Rule: Repeated Failed Sign-Ins

1. **Log Analytics workspace** → **Alerts** → **+ Create** → **Alert rule**
2. **Scope**: your Log Analytics workspace
3. **Condition**: Custom log search → paste `failed-signins.kql`
4. **Threshold**: Number of results > 0, evaluated every 15 minutes over a 1-hour window
5. **Action group**: create one that sends an email notification to yourself
6. **Alert rule details**: name it `Failed Sign-In Threshold Exceeded`, set severity to
   Warning (Sev 2)
7. Review + create

📸 **Screenshot:** Alert rule configuration showing the KQL query and threshold.
📸 **Screenshot:** A triggered alert (or the alert rule's "Fired alerts" history) if you
generate test failed sign-ins to trigger it.

## Cost Note

Scheduled query alert rules are billed per rule, per evaluation frequency - typically a
small fraction of a dollar per month for a single rule evaluated every 15 minutes at
lab scale. This isn't strictly "free tier" but is negligible cost; worth being upfront
about this rather than calling it free, since a recruiter with Azure experience will
know scheduled query rules aren't a free SKU.

## Alternative: Zero-Cost Option

If you want to avoid even the small alert rule cost, skip the alert rule and instead
just run the KQL queries manually/on a schedule you set yourself, screenshotting the
query results directly. This still demonstrates the monitoring capability without
incurring the alert evaluation cost - a reasonable trade-off to document in your README
if cost is a hard constraint.
