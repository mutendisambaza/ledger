# 🚀 Quick Start: Fix OAuth 404 Error

## ⏱️ 6-Minute Setup

### ✅ Already Done (Automated)
- Updated `Info.plist` with Google SDK config
- Refactored `GoogleAuthManager` to use official SDK
- Removed deprecated OAuth code

### 🔧 Do This Now (Manual)

#### 1️⃣ Add SDK (2 min)
**In Xcode:**
```
File → Add Package Dependencies
URL: https://github.com/google/GoogleSignIn-iOS
Version: 7.0.0+
✓ GoogleSignIn
✓ GoogleSignInSwift
```

#### 2️⃣ Fix Info.plist (1 min)
**In Xcode:**
```
Target: ledger → Build Settings
Search: "Info.plist"
Set "Info.plist File" to: ledger/Info.plist
Set "Generate Info.plist File" to: NO
```

#### 3️⃣ Update Google Cloud (3 min)
**In [Console](https://console.cloud.google.com/):**
```
APIs & Services → Credentials
Edit OAuth Client (879598092731-...)

❌ REMOVE: com.taurai.ledger://oauth/callback
✅ ADD: com.googleusercontent.apps.879598092731-sn5unu43moo46vveb1gkeb002fdvaknt:/oauth

Save
```

### ✅ Test It
```bash
# Build in Xcode
⌘+R

# Tap "Continue with Gmail"
# Should work now! 🎉
```

### 📖 Need Details?
- Full guide: `OAUTH_SETUP_GUIDE.md`
- Migration info: `MIGRATION_SUMMARY.md`
- Verify setup: `bash scripts/setup-google-signin.sh`

---
**Why did this happen?**
Google deprecated custom URL schemes (security). Now using official SDK.
