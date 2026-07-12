# Entra ID Security Defaults

Security Defaults is the free-tier baseline security control in Entra ID.

## Where to Enable
1. Entra ID -> Overview -> Properties
2. Manage security defaults -> Enabled -> Save

## Important Notes
- Security Defaults and Conditional Access are mutually exclusive.
- MFA under Security Defaults is limited to Microsoft Authenticator only.

## Verifying Enforcement
Sign in as a test user - you should be prompted for MFA.