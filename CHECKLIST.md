# OAuth Setup Checklist

## Automated (Already Done ✅)
- [x] Created `Info.plist` with Google SDK configuration
- [x] Updated `GoogleAuthManager.swift` to use Google Sign-In SDK
- [x] Removed deprecated redirect URI from `AppConfig.swift`
- [x] Removed ~150 lines of manual OAuth code
- [x] Created setup scripts and documentation

## Manual Steps (You Do This)

### Step 1: Add Google Sign-In SDK
- [ ] Open Xcode (File → Add Package Dependencies)
- [ ] Enter URL: `https://github.com/google/GoogleSignIn-iOS`
- [ ] Select version 7.0.0 or later
- [ ] Check both: `GoogleSignIn` and `GoogleSignInSwift`
- [ ] Click "Add Package"
- [ ] Wait for download to complete

### Step 2: Configure Info.plist in Xcode
- [ ] Select "ledger" target in Xcode
- [ ] Go to "Build Settings" tab
- [ ] Search for "Info.plist" in the filter
- [ ] Find "Info.plist File" setting
- [ ] Change value to: `ledger/Info.plist`
- [ ] Find "Generate Info.plist File" setting
- [ ] Change value to: `NO`
- [ ] Build project (⌘+B) to verify no errors

### Step 3: Update Google Cloud Console
- [ ] Go to https://console.cloud.google.com/
- [ ] Navigate to: APIs & Services → Credentials
- [ ] Find OAuth 2.0 Client ID: `879598092731-sn5unu43moo46vveb1gkeb002fdvaknt`
- [ ] Click "Edit" (pencil icon)
- [ ] Under "Authorized redirect URIs":
  - [ ] **Remove**: `com.taurai.ledger://oauth/callback`
  - [ ] **Add**: `com.googleusercontent.apps.879598092731-sn5unu43moo46vveb1gkeb002fdvaknt:/oauth`
- [ ] Click "Save"
- [ ] Verify "Application type" is set to "iOS"
- [ ] Verify "Bundle ID" is `taurai.ledger` or `com.taurai.ledger`

### Step 4: Enable Gmail API
- [ ] In Google Cloud Console: APIs & Services → Library
- [ ] Search for "Gmail API"
- [ ] Click "Enable" (if not already enabled)

### Step 5: Add Test User (if in Testing mode)
- [ ] Go to: APIs & Services → OAuth consent screen
- [ ] Check if status is "Testing"
- [ ] If Testing, click "Add Users" under "Test users"
- [ ] Add your Gmail address
- [ ] Click "Save"

### Step 6: Verify Setup
- [ ] Run verification script: `bash scripts/setup-google-signin.sh`
- [ ] All checks should pass ✓

### Step 7: Test OAuth Flow
- [ ] Build and run app in Xcode (⌘+R)
- [ ] App should show sign-in screen
- [ ] Tap "Continue with Gmail"
- [ ] Google Sign-In UI should appear (not 404!)
- [ ] Select your test account
- [ ] Grant Gmail read permissions
- [ ] Should redirect back to app
- [ ] HomeView should appear
- [ ] Tap "Sync from Gmail"
- [ ] Transactions should populate

## Troubleshooting

### If you see "redirect_uri_mismatch"
- [ ] Double-check redirect URI in Google Cloud Console
- [ ] Make sure it's exactly: `com.googleusercontent.apps.879598092731-sn5unu43moo46vveb1gkeb002fdvaknt:/oauth`
- [ ] No extra spaces or characters

### If you see "Access not configured"
- [ ] Make sure Gmail API is enabled
- [ ] Wait a few minutes for changes to propagate

### If you see build errors
- [ ] Verify Google Sign-In SDK was added correctly
- [ ] Check that Info.plist path is set correctly
- [ ] Clean build folder (⇧⌘K) and rebuild

### If sign-in button does nothing
- [ ] Check Xcode console for error messages
- [ ] Verify test user is added in Google Cloud Console
- [ ] Make sure OAuth consent screen is configured

## Success Criteria ✨
- [ ] No 404 errors during sign-in
- [ ] Google Sign-In UI appears smoothly
- [ ] Successfully signs in with test account
- [ ] Transactions sync from Gmail
- [ ] Lock screen widget shows daily total

## Time Estimate
- Step 1: 2 minutes
- Step 2: 1 minute
- Step 3-5: 3 minutes
- Step 6-7: 2 minutes
- **Total: ~8 minutes**

---

**Having issues?** Check:
1. `OAUTH_SETUP_GUIDE.md` - Detailed instructions
2. `MIGRATION_SUMMARY.md` - Why we did this
3. `QUICK_START.md` - Condensed version
