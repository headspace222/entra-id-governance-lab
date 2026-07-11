# Entra ID Security Defaults

Security Defaults is the free-tier baseline security control in Entra ID - a single
on/off toggle (not a customizable policy) that enforces:

- All users must register for and use Microsoft Authenticator for MFA
- Legacy authentication protocols are blocked tenant-wide
- Admins must complete MFA challenges for privileged actions
- Users must complete MFA challenges when a sign-in is deemed risky

## Where to Enable

1. **Entra ID** → **Overview** → **Properties**
2. Select **Manage security defaults**
3. Set **Security defaults** to **Enabled**
4. Save

📸 **Screenshot:** Security defaults toggle set to Enabled, in the Properties blade.

## Important Notes

- Security Defaults and Conditional Access are mutually exclusive - enabling any
  Conditional Access policy (which requires P1) automatically disables Security
  Defaults. This lab uses Security Defaults specifically because it doesn't require
  premium licensing.
- After enabling, there's a 24-hour grace period before enforcement begins, giving
  time to ensure admin accounts have MFA registered before it becomes mandatory.
- MFA under Security Defaults is limited to the Microsoft Authenticator app only - no
  SMS, phone call, or FIDO2 key support. This is a real limitation worth naming
  directly: production environments with diverse device/user needs generally require
  Conditional Access (P1+) for a workable MFA rollout at scale.

## Verifying Enforcement

After enabling, sign in as a test user without Authenticator registered - you should
be prompted to set up MFA registration before being allowed to proceed.

📸 **Screenshot:** MFA registration prompt shown to an unregistered user after Security
Defaults enforcement begins.
