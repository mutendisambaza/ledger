# Fix OAuth 2.0 Policy Compliance Error

If you see **"This app doesn't comply with Google's OAuth 2.0 policy"**, fix the OAuth consent screen and OAuth client as below.

## 1. OAuth client (API & Services → Credentials)

- Ensure there is an **iOS** OAuth 2.0 Client ID (not a Web or Desktop client).
- **Bundle ID** must be exactly: `taurai.ledger` (to match the app’s bundle ID in Xcode).
- If you only have a Web client, create a new **iOS** client and set the bundle ID; then update `AppConfig.GoogleOAuth.clientId` in the app.

## 2. OAuth Consent Screen

### 2.1 Open the consent screen
- https://console.cloud.google.com/apis/credentials/consent?project=ledger-485202

### 2.2 Edit the app
- Click **"Edit App"** (or **"Edit"**).

### 2.3 App information (Step 1)

| Field | Required | What to use |
|-------|----------|-------------|
| **App name** | Yes | `Ledger` |
| **User support email** | Yes | Your email |
| **App logo** | No | Optional |
| **App domain** | No | e.g. `ledger.app` or blank |
| **Application home page** | No | Blank or your site |
| **Privacy policy link** | Yes (for Gmail) | See below |
| **Terms of service link** | No | Optional |
| **Authorized domains** | No | Blank for testing |

**Privacy policy link**

- Host `Docs/privacy.html` (in this repo) on any public URL, e.g. GitHub Pages, then use that URL.
- Example: `https://yourusername.github.io/ledger/privacy.html` or `https://yoursite.com/privacy`.
- For quick testing, a placeholder like `https://example.com/privacy` may work; a real page is better.

**Step 2: Scopes**
- Verify `https://www.googleapis.com/auth/gmail.readonly` is listed
- Click "Save and Continue"

**Step 3: Test Users** ⚠️ **CRITICAL**
- Click "Add Users"
- Enter your email address (the one you'll use to sign in)
- Click "Add"
- Click "Save and Continue"

**Step 4: Summary**
- Review the information
- Click "Back to Dashboard"

### 4. Wait a Few Minutes
Changes can take 2-5 minutes to propagate.

### 5. Try Signing In Again
Open the app and try the "Sign in with Gmail" button again.

## Common Issues

### "Privacy policy link is required"
For testing, you can:
1. Create a simple GitHub Pages site with a privacy policy
2. Use a placeholder URL temporarily (may work for testing)
3. Host a simple HTML page with your privacy policy

**Example privacy policy content** (minimal for testing):
```html
<!DOCTYPE html>
<html>
<head>
    <title>Ledger Privacy Policy</title>
</head>
<body>
    <h1>Privacy Policy</h1>
    <p>Ledger is a personal finance tracking app that reads Gmail receipts to track spending.</p>
    <p>We only access Gmail messages with receipt-related keywords and do not store or share your email content.</p>
    <p>All data is stored locally on your device.</p>
</body>
</html>
```

### "User is not a test user"
- Make sure you added your email in Step 3 above
- Wait 2-5 minutes after adding
- Try signing in again

### Still Getting Errors?
1. Check the exact error message in the browser
2. Go back to the OAuth Consent Screen and verify all fields are filled
3. Make sure you clicked "Save and Continue" on each step
4. Check that your email is in the Test Users list

## For Production (Later)

When you're ready to publish:
1. Create a proper privacy policy page
2. Add your actual app domain
3. Complete Google's verification process (can take days/weeks)
4. Click "Publish App" in the consent screen

For now, the testing configuration should work once all required fields are filled.
