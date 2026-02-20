# Google Cloud Console Setup & Management Guide

This document contains important links and instructions for managing the Ledger app's Google Cloud configuration.

## Project Information

- **Project Name**: Ledger
- **Project ID**: `ledger-485202`
- **OAuth Client ID**: `879598092731-sn5unu43moo46vveb1gkeb002fdvaknt.apps.googleusercontent.com`
  - ⚠️ **Note**: OAuth Client IDs for mobile apps are public by design (embedded in app binary)
  - This is not a secret and is safe to include in code
- **Bundle ID**: `com.taurai.ledger`

## ⚠️ Security Notes

**What is Safe to Commit:**
- ✅ OAuth Client IDs (public by design for mobile apps)
- ✅ Bundle IDs
- ✅ Project IDs
- ✅ API endpoints

**What Should NEVER Be Committed:**
- ❌ OAuth Client Secrets (iOS OAuth doesn't use these)
- ❌ Refresh Tokens (stored in Keychain, not in code)
- ❌ Access Tokens (temporary, stored in Keychain)
- ❌ Private API keys
- ❌ Service account JSON files
- ❌ Any credentials with write/delete permissions

## Quick Links

### OAuth & Authentication
- **OAuth Consent Screen**: https://console.cloud.google.com/apis/credentials/consent?project=ledger-485202
- **OAuth Clients**: https://console.cloud.google.com/auth/clients?project=ledger-485202
- **Audience Settings**: https://console.cloud.google.com/auth/audience?project=ledger-485202
- **OAuth Overview**: https://console.cloud.google.com/auth/overview?project=ledger-485202

### APIs & Services
- **Gmail API Library**: https://console.cloud.google.com/apis/library/gmail.googleapis.com?project=ledger-485202
- **Gmail API Metrics**: https://console.cloud.google.com/apis/api/gmail.googleapis.com/metrics?project=ledger-485202
- **Enabled APIs Dashboard**: https://console.cloud.google.com/apis/dashboard?project=ledger-485202
- **API Credentials**: https://console.cloud.google.com/apis/credentials?project=ledger-485202

### Project Management
- **Project Settings**: https://console.cloud.google.com/iam-admin/settings?project=ledger-485202
- **Project Selector**: https://console.cloud.google.com/projectselector2/home/dashboard

## Common Tasks

### 1. Add/Remove Test Users

**To add a test user:**
1. Go to [OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent?project=ledger-485202)
2. Scroll down to "Test users" section
3. Click "Add Users"
4. Enter email addresses (one per line)
5. Click "Add"

**To remove a test user:**
1. Go to [OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent?project=ledger-485202)
2. Scroll to "Test users" section
3. Click the "X" next to the user you want to remove

**Note**: Since the app is in "External" mode, only test users can sign in. You must add yourself as a test user to use the app.

### 2. Enable/Disable Gmail API

**To enable Gmail API:**
1. Go to [Gmail API Library](https://console.cloud.google.com/apis/library/gmail.googleapis.com?project=ledger-485202)
2. Click the "Enable" button
3. Wait for confirmation

**To disable Gmail API:**
1. Go to [Enabled APIs Dashboard](https://console.cloud.google.com/apis/dashboard?project=ledger-485202)
2. Find "Gmail API" in the list
3. Click on it to open details
4. Click "Disable API" button
5. Confirm the action

### 3. View API Usage & Metrics

**To view Gmail API metrics:**
1. Go to [Gmail API Metrics](https://console.cloud.google.com/apis/api/gmail.googleapis.com/metrics?project=ledger-485202)
2. View requests, errors, and quota usage

**To view all API metrics:**
1. Go to [Enabled APIs Dashboard](https://console.cloud.google.com/apis/dashboard?project=ledger-485202)
2. Click on any API to see its metrics

### 4. Manage OAuth Clients

**To view all OAuth clients:**
1. Go to [OAuth Clients](https://console.cloud.google.com/auth/clients?project=ledger-485202)
2. See list of all created clients

**To edit an OAuth client:**
1. Go to [OAuth Clients](https://console.cloud.google.com/auth/clients?project=ledger-485202)
2. Click on the client name (e.g., "Ledger iOS")
3. Edit fields as needed
4. Click "Save"

**To delete an OAuth client:**
1. Go to [OAuth Clients](https://console.cloud.google.com/auth/clients?project=ledger-485202)
2. Select the checkbox next to the client
3. Click "Delete" button
4. Confirm deletion

**To create a new OAuth client:**
1. Go to [OAuth Clients](https://console.cloud.google.com/auth/clients?project=ledger-485202)
2. Click "Create client"
3. Select application type (iOS, Android, Web, etc.)
4. Fill in required fields
5. Click "Create"

### 5. Change OAuth Consent Screen Settings

**To edit consent screen:**
1. Go to [OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent?project=ledger-485202)
2. Click "Edit App" button
3. Modify:
   - App name
   - User support email
   - App logo
   - App domain
   - Authorized domains
   - Scopes
   - Test users
4. Click "Save and Continue" through all steps

**To change audience (Internal vs External):**
1. Go to [Audience Settings](https://console.cloud.google.com/auth/audience?project=ledger-485202)
2. Click "Edit" if needed
3. Select "Internal" or "External"
4. Save changes

**Note**: Changing from External to Internal requires Google Workspace organization.

### 6. View/Download OAuth Client Credentials

**To view client ID:**
1. Go to [OAuth Clients](https://console.cloud.google.com/auth/clients?project=ledger-485202)
2. Click on the client name
3. View the Client ID (displayed at the top)

**To download client configuration (iOS):**
1. Go to [OAuth Clients](https://console.cloud.google.com/auth/clients?project=ledger-485202)
2. Click on the iOS client
3. Click "Download plist" button
4. Save the `GoogleService-Info.plist` file

### 7. Remove/Revoke API Access

**To revoke Gmail API access for the app:**
1. Go to [Enabled APIs Dashboard](https://console.cloud.google.com/apis/dashboard?project=ledger-485202)
2. Find "Gmail API"
3. Click on it
4. Click "Disable API"
5. Confirm

**To revoke OAuth tokens (user-level):**
- Users can revoke access at: https://myaccount.google.com/permissions
- Or you can delete the OAuth client to prevent new authorizations

### 8. Delete the Entire Project

**Warning**: This will delete ALL resources, APIs, and configurations!

1. Go to [Project Settings](https://console.cloud.google.com/iam-admin/settings?project=ledger-485202)
2. Click "Shut down" or "Delete"
3. Enter project ID to confirm: `ledger-485202`
4. Click "Shut down" or "Delete"

**Alternative method:**
1. Go to [Project Selector](https://console.cloud.google.com/projectselector2/home/dashboard)
2. Select the "Ledger" project
3. Click the three dots menu (⋮)
4. Select "Delete"
5. Confirm deletion

### 9. Check API Quotas & Limits

**To view Gmail API quotas:**
1. Go to [Gmail API Metrics](https://console.cloud.google.com/apis/api/gmail.googleapis.com/metrics?project=ledger-485202)
2. Check "Quotas" tab
3. View:
   - Requests per day
   - Requests per 100 seconds per user
   - Requests per 100 seconds

**To request quota increase:**
1. Go to [Gmail API Metrics](https://console.cloud.google.com/apis/api/gmail.googleapis.com/metrics?project=ledger-485202)
2. Click "Quotas" tab
3. Click "Edit Quotas" or "Request Increase"
4. Fill out the form
5. Submit request

### 10. Monitor API Errors

**To view API errors:**
1. Go to [Gmail API Metrics](https://console.cloud.google.com/apis/api/gmail.googleapis.com/metrics?project=ledger-485202)
2. Check "Errors" tab
3. View error types and counts
4. Click on specific errors for details

## Important Notes

### Testing Mode (Current Status)
- The app is currently in **External** mode with **Testing** status
- Only test users can sign in
- You must add test users in the OAuth consent screen
- No verification required for testing

### Publishing the App
If you want to make the app available to all users:
1. Go to [OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent?project=ledger-485202)
2. Click "Publish App"
3. Complete Google's verification process (required for sensitive scopes like Gmail)
4. Verification can take several days to weeks

### Security Best Practices
- Never commit OAuth Client IDs or secrets to version control
- Regularly review and remove unused OAuth clients
- Monitor API usage for unusual activity
- Use test users during development
- Rotate credentials if compromised

## Troubleshooting

### "Access blocked: This app's request is invalid"
- Check that the OAuth client ID matches in your code
- Verify the bundle ID matches the OAuth client configuration
- Ensure the redirect URI is correctly configured

### "This app doesn't comply with Google's OAuth 2.0 policy" ⚠️ COMMON ISSUE
This error occurs when the OAuth consent screen is missing required information. **For apps using sensitive scopes like Gmail, Google requires:**

1. **Go to OAuth Consent Screen**: https://console.cloud.google.com/apis/credentials/consent?project=ledger-485202
2. **Click "Edit App"**
3. **Fill in ALL required fields:**
   - ✅ **App name**: "Ledger" (or your app name)
   - ✅ **User support email**: Your email address (required)
   - ✅ **App logo**: Optional but recommended
   - ✅ **App domain**: Leave blank or use a placeholder (e.g., "ledger.app")
   - ✅ **Authorized domains**: Leave blank for testing, or add your domain
   - ✅ **Developer contact information**: Your email (required)
4. **Click "Save and Continue"**
5. **On the Scopes page:**
   - Verify `https://www.googleapis.com/auth/gmail.readonly` is listed
   - Click "Save and Continue"
6. **On the Test users page:**
   - ⚠️ **CRITICAL**: Add your email address as a test user
   - Click "Add Users" and enter your email
   - Click "Save and Continue"
7. **Review and submit**

**Common missing fields that cause this error:**
- ❌ User support email not set
- ❌ Developer contact information not set
- ❌ Test user not added (if in Testing mode)
- ❌ App domain not set (sometimes required)

**Note**: Even in Testing mode, you must complete all required fields in the consent screen.

### "User is not a test user"
- Add the user's email to test users in OAuth consent screen
- Wait a few minutes for changes to propagate
- Make sure you clicked "Save and Continue" after adding test users

### "API not enabled"
- Enable Gmail API from the API Library
- Wait a few minutes for activation

### "Quota exceeded"
- Check API usage in metrics
- Request quota increase if needed
- Implement rate limiting in your app

## Code References

The OAuth Client ID is configured in:
- `ledger/App/AppConfig.swift` - `AppConfig.GoogleOAuth.clientId`

If you change the Client ID, update it in `AppConfig.swift`. This centralizes all configuration.

**Security Note**: OAuth Client IDs for mobile apps are intentionally public (embedded in the app binary). They are not secrets. The real security comes from:
- OAuth scopes limiting what the app can access
- User consent required for each authorization
- Tokens stored securely in iOS Keychain (not in code)

