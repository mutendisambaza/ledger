# Security Guide

This document outlines security best practices for the Ledger app.

## 🔐 What is Safe to Commit to Git

### ✅ Safe to Commit (Public Information)
- **OAuth Client IDs** - These are intentionally public for mobile apps
  - Location: `ledger/App/AppConfig.swift`
  - Why safe: Embedded in app binary, visible to anyone who downloads the app
  - Example: `879598092731-sn5unu43moo46vveb1gkeb002fdvaknt.apps.googleusercontent.com`

- **Bundle IDs** - Public identifiers
  - Example: `com.taurai.ledger`

- **Project IDs** - Public Google Cloud identifiers
  - Example: `ledger-485202`

- **API Endpoints** - Public URLs
  - Example: `https://www.googleapis.com/gmail/v1/`

- **OAuth Scopes** - Public permission requests
  - Example: `https://www.googleapis.com/auth/gmail.readonly`

### ❌ Never Commit (Sensitive Information)

- **OAuth Client Secrets** - Not used by iOS OAuth, but if you add web support, never commit these
- **Refresh Tokens** - Stored in iOS Keychain, never in code
- **Access Tokens** - Temporary, stored in iOS Keychain, never in code
- **Service Account JSON Files** - Contains private keys
- **API Keys with Write/Delete Permissions** - Could allow unauthorized access
- **User Credentials** - Passwords, PINs, etc.
- **Personal Information** - User emails, names (unless anonymized)

## 🛡️ Current Security Measures

### 1. Token Storage
- ✅ **Refresh Tokens**: Stored in iOS Keychain via `KeychainStore`
- ✅ **Access Tokens**: Stored in iOS Keychain (temporary)
- ✅ **Keychain Access Groups**: Configured in entitlements
- ✅ **No tokens in code**: All tokens are runtime-only, stored securely

### 2. OAuth Flow
- ✅ **ASWebAuthenticationSession**: Uses secure browser session
- ✅ **Custom URL Scheme**: `com.taurai.ledger://oauth/callback`
- ✅ **Read-only Scope**: `gmail.readonly` - cannot modify emails
- ✅ **User Consent**: Required for each authorization

### 3. App Group Security
- ✅ **App Group ID**: `group.com.taurai.ledger`
- ✅ **UserDefaults**: Only stores non-sensitive data (totals, dates)
- ✅ **No tokens in App Group**: Tokens stay in Keychain

### 4. Code Organization
- ✅ **Centralized Config**: OAuth settings in `AppConfig.swift`
- ✅ **No Hardcoded Secrets**: All sensitive data in Keychain
- ✅ **Error Handling**: Prevents token leakage in error messages

## 📋 Security Checklist

### Before Committing Code
- [ ] No tokens or secrets in code
- [ ] No hardcoded credentials
- [ ] No service account JSON files
- [ ] `.gitignore` includes sensitive file patterns
- [ ] OAuth Client ID is in `AppConfig.swift` (safe to commit)

### Before Publishing
- [ ] Review all API permissions (read-only where possible)
- [ ] Verify OAuth scopes are minimal (only `gmail.readonly`)
- [ ] Test that tokens are properly cleared on sign out
- [ ] Verify Keychain items are properly scoped
- [ ] Check that no sensitive data is logged to console

### Regular Maintenance
- [ ] Rotate OAuth Client ID if compromised
- [ ] Review Google Cloud API quotas and limits
- [ ] Monitor for unusual API usage
- [ ] Keep dependencies updated
- [ ] Review access logs in Google Cloud Console

## 🔍 How to Verify Security

### Check for Exposed Secrets
```bash
# Search for potential secrets in code
grep -r "password\|secret\|token\|key" --include="*.swift" ledger/ | grep -v "//\|Keychain\|Token\|ClientId"

# Check for hardcoded tokens
grep -r "ya29\." ledger/  # Google access tokens start with ya29.

# Verify .gitignore is working
git status --ignored
```

### Verify Keychain Storage
1. Open Keychain Access app on Mac
2. Search for "ledger" or "com.taurai.ledger"
3. Verify tokens are stored securely
4. Check that tokens are not in plain text files

### Verify App Group
1. Check that App Group only contains:
   - `today_total_cents` (integer)
   - `last_updated_iso` (date string)
   - `today_date_iso` (date string)
   - `transactions_json` (transaction data - no tokens)
2. No tokens or credentials in App Group UserDefaults

## 🚨 If Secrets Are Compromised

### If OAuth Client ID is Compromised
1. **Don't Panic**: Client IDs are public by design
2. **Review Access**: Check Google Cloud Console for unusual activity
3. **Rotate if Needed**: Create new OAuth client and update `AppConfig.swift`
4. **Revoke Tokens**: Users can revoke at https://myaccount.google.com/permissions

### If Tokens Are Compromised
1. **Immediate Action**: Revoke all tokens in Google Cloud Console
2. **Force Re-auth**: Users must sign in again
3. **Review Logs**: Check for unauthorized API calls
4. **Update Code**: Ensure tokens are properly cleared

### If Project is Compromised
1. **Disable API**: Disable Gmail API in Google Cloud Console
2. **Review Permissions**: Check IAM settings
3. **Rotate Credentials**: Create new OAuth clients
4. **Consider New Project**: If severely compromised, create new project

## 📚 Additional Resources

- [Google OAuth 2.0 Security Best Practices](https://developers.google.com/identity/protocols/oauth2/security-best-practices)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

## 🔗 Related Documentation

- [`google-cloud-setup.md`](./google-cloud-setup.md) - Google Cloud configuration
- [`PHASE2_STATE_REPORT.md`](./PHASE2_STATE_REPORT.md) - Current project status

---

**Last Updated**: January 22, 2026  
**Security Contact**: Review this document before any security-related changes

