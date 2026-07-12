# Sign-In Monitoring

## Primary Method: Native Sign-In Log Filtering (Free Tier)

### Failed Sign-In Detection
1. Entra ID -> Monitoring & health -> Sign-in logs
2. Add filter -> Status -> Failure
3. Review results.

### Legacy Authentication Detection
1. Same Sign-in logs view
2. Add filter -> Client app -> Legacy Authentication Clients
3. "No sign-ins found" is the desired outcome.

### Why This Instead of Log Analytics Export
Streaming sign-in logs to Log Analytics requires Entra ID P1 or P2 licensing
tenant-wide. This lab uses the native sign-in log viewer's built-in filtering as the
primary, guaranteed-free method instead.

## Optional Extension: Log Analytics + KQL (Requires P1/P2)

See monitoring/kql-queries/ for the enterprise-scale equivalent if you have P1/P2
available.