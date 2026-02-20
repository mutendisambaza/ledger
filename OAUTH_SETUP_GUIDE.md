# Google OAuth 2.0 Setup Guide for Ledger

## 🎯 Overview

This guide will help you complete the Google Sign-In SDK integration and fix the OAuth 404 error.

## ✅ Completed Steps

1. ✅ Updated `Info.plist` with Google Sign-In SDK configuration
2. ✅ Refactored `GoogleAuthManager` to use Google Sign-In SDK
3. ✅ Updated `AppConfig` to remove deprecated redirect URI
4. ✅ Code is ready for Google Sign-In SDK

## 📦 Step 1: Add Google Sign-In SDK via Swift Package Manager

**In Xcode (already opened):**

1. Select your project in the navigator (ledger.xcodeproj)
2. Select the **ledger** target
3. Go to **General** tab
4. Scroll down to **Frameworks, Libraries, and Embedded Content**
5. Click the **+** button
6. Click **Add Package Dependency...**
7. Enter the URL: `https://github.com/google/GoogleSignIn-iOS`
8. Click **Add Package**
9. Select version **7.0.0** or later
10. Make sure **GoogleSignIn** and **GoogleSignInSwift** are both checked
11. Click **Add Package**

## 🔧 Step 2: Update Xcode Build Settings

Since we created a custom `Info.plist`, we need to tell Xcode to use it:

1. In Xcode, select the **ledger** target
2. Go to **Build Settings** tab
3. Search for "Info.plist"
4. Find **Info.plist File** setting
5. Set the value to: `ledger/Info.plist`
6. Build the project (⌘+B) to verify no errors

## ☁️ Step 3: Configure Google Cloud Console

### Update OAuth Client Configuration

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** → **Credentials**
4. Find your OAuth 2.0 Client ID:
   ```
   879598092731-sn5unu43moo46vveb1gkeb002fdvaknt.apps.googleusercontent.com
   ```

### Update Redirect URIs

**IMPORTANT:** Remove the old custom URL scheme and add the SDK-compatible redirect URI:

1. Click **Edit OAuth client**
2. Under **Authorized redirect URIs**, remove:
   ```
   com.taurai.ledger://oauth/callback
   ```
3. Add the reversed client ID (this is what the SDK uses):
   ```
   com.googleusercontent.apps.879598092731-sn5unu43moo46vveb1gkeb002fdvaknt:/oauth
   ```
4. Click **Save**

### Verify Bundle Identifier

Make sure your iOS app bundle identifier matches:
- **Bundle Identifier in Google Cloud**: Should be `taurai.ledger` or `com.taurai.ledger`
- Check **Application type** is set to **iOS**

### Enable Gmail API

1. In Google Cloud Console, go to **APIs & Services** → **Library**
2. Search for "Gmail API"
3. Click **Enable** if not already enabled

### Add Test Users (for development)

If your OAuth consent screen is in "Testing" mode:

1. Go to **APIs & Services** → **OAuth consent screen**
2. Under **Test users**, click **Add Users**
3. Add your Gmail address that you'll use for testing
4. Click **Save**

## 🧪 Step 4: Test the OAuth Flow

### Build and Run

1. In Xcode, select an iOS Simulator or connected device
2. Press **⌘+R** to build and run
3. You should see the beautiful sign-in screen

### Test Sign-In

1. Tap **Continue with Gmail**
2. You should see the Google Sign-In UI (not a web view)
3. Select your test account
4. Grant permissions for Gmail access
5. You should be redirected back to the app
6. The app should show the HomeView with your transactions

### Troubleshooting

If you encounter errors:

**Error: "No bundle URL types are configured"**
- Solution: Make sure `Info.plist` is correctly set in Build Settings

**Error: "redirect_uri_mismatch"**
- Solution: Verify the redirect URI in Google Cloud Console matches:
  `com.googleusercontent.apps.879598092731-sn5unu43moo46vveb1gkeb002fdvaknt:/oauth`

**Error: "Access not configured"**
- Solution: Enable Gmail API in Google Cloud Console

**Error: "OAuth consent screen not configured"**
- Solution: Configure OAuth consent screen and add test users

## 📝 What Changed

### Files Modified

1. **`Info.plist`** (new file)
   - Added Google Sign-In SDK URL scheme
   - Added GIDClientID for SDK configuration

2. **`GoogleAuthManager.swift`**
   - Replaced ASWebAuthenticationSession with Google Sign-In SDK
   - Simplified token management (SDK handles refresh automatically)
   - Removed custom OAuth flow code
   - Added `restorePreviousSignIn()` support

3. **`AppConfig.swift`**
   - Removed deprecated `redirectURI` constant
   - Added documentation about SDK usage

### Benefits of This Migration

✅ **Security**: No risk of app impersonation with custom URL schemes
✅ **Maintenance**: Google maintains the SDK and security updates
✅ **Simplicity**: ~100 fewer lines of code
✅ **Reliability**: Handles edge cases, token refresh, and error recovery
✅ **Future-proof**: Won't break with Google OAuth policy changes

## 🔐 Security Notes

- Client IDs for mobile apps are **public by design** (embedded in app binary)
- Real security comes from:
  - Bundle identifier verification
  - App signing certificates
  - Google's App Check (optional, for production)
- Never store client secrets in mobile apps

## 🚀 Next Steps

After successful sign-in:

1. Tap **Sync from Gmail** to fetch receipts
2. Watch transactions populate
3. Check the lock screen widget for daily total
4. Enjoy passive financial tracking!

## 📚 Resources

- [Google Sign-In SDK Documentation](https://developers.google.com/identity/sign-in/ios/sign-in)
- [OAuth 2.0 for Native Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
- [Google Cloud Console](https://console.cloud.google.com/)

## ❓ Need Help?

If you encounter issues:
1. Check Xcode console for detailed error messages
2. Verify all configuration steps above
3. Make sure test user is added in Google Cloud Console
4. Try cleaning the build folder (⇧⌘K) and rebuilding
