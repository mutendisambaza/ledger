# Ledger

**A passive financial observer for iOS**

Ledger automatically tracks your daily spending by parsing receipt emails from Gmail. No manual entry, no celebrations, no alarms—just calm, observational awareness of your spending patterns.

---

## 🎯 Core Concept

Ledger reads your Gmail receipt emails, extracts transaction amounts with confidence scoring, and displays your daily spending totals on both the main app and lock screen widgets.

**Design Philosophy:** Passive observation. The app notices your spending patterns without being intrusive or judgmental.

---

## ✨ Features

- **Automatic Receipt Parsing** - Scans Gmail for receipts and extracts amounts
- **Confidence Scoring** - ML-like scoring prevents false positives
- **Lock Screen Widget** - Daily total at a glance
- **Spending Insights** - Pattern detection for accumulation, velocity, and unusual amounts
- **Multi-Currency Support** - CAD, USD, EUR, GBP
- **Privacy-First** - Read-only Gmail access, local storage, manual sync

---

## 🏗 Architecture

### 4-Layer System

1. **Authentication** - Google Sign-In SDK with secure Keychain storage
2. **Data Fetching** - Gmail API client (last 24 hours)
3. **Intelligence** - Receipt parser with confidence-based extraction
4. **Presentation** - SwiftUI app + WidgetKit lock screen widget

### Tech Stack

- **Swift + SwiftUI** - iOS app development
- **WidgetKit** - Lock screen widget
- **Gmail API v1** - Receipt fetching
- **Google Sign-In SDK 9.x** - OAuth 2.0 authentication
- **App Groups** - Widget data sharing
- **Security Framework** - Keychain token storage

---

## 📦 Project Structure

```
ledger/
├── App/           # Entry point & AppConfig
├── Auth/          # Google Sign-In SDK & Keychain
├── Gmail/         # Gmail API client
├── Parsing/       # Receipt parser w/ confidence scoring
├── Storage/       # Data models & LedgerStore singleton
├── UI/            # SwiftUI views & components
├── Insights/      # Spending pattern detection
└── LedgerWidget/  # Lock screen widget
```

---

## 🚀 Setup

### Prerequisites

- Xcode 26.2+
- iOS 26.2+ / macOS 26.0+
- Google Cloud project with Gmail API enabled
- Apple Developer account (for device testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ledger
   ```

2. **Open in Xcode**
   ```bash
   open ledger/ledger.xcodeproj
   ```

3. **Configure Google Cloud Console**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Gmail API
   - Create iOS OAuth 2.0 Client ID
   - Set Bundle ID: `taurai.ledger`
   - Add test users (if in Testing mode)

4. **Build and Run**
   - Select a simulator or device
   - Press ⌘+R

---

## 🔐 Security & Privacy

- **No Server** - All data stored locally on device
- **Read-Only Gmail** - Only reads emails, never sends or modifies
- **Manual Sync** - User controls when data is fetched
- **Keychain Storage** - OAuth tokens encrypted in iOS Keychain
- **App Sandbox** - Full sandboxing enabled

### OAuth Configuration

The app uses **Google Sign-In SDK** (not custom URL schemes):
- Client ID: Configured in `AppConfig.swift`
- Redirect URI: Handled automatically by SDK
- Scopes: `gmail.readonly` only

**Note:** Client IDs for mobile apps are public by design (embedded in binary). Security comes from bundle ID verification and app signing.

---

## 📱 Usage

1. **Sign In** - Tap "Continue with Gmail"
2. **Grant Permissions** - Allow Gmail read-only access
3. **Sync Receipts** - Tap "Sync from Gmail" to fetch recent receipts
4. **View Spending** - See daily totals and transaction list
5. **Check Widget** - Add lock screen widget for at-a-glance totals

---

## 🎨 Design System

### Colors (Dark Mode)
- Background: `#0B0B0C`
- Accent: `#3B82F6` (blue)
- Text: `#FAFAFA` (white)
- Secondary: `#A1A1AA` (gray)

### Typography
- **Display**: SF Pro (Bold, 32pt)
- **Body**: SF Pro (Regular, 15pt)
- **Amounts**: SF Mono (Medium, 20pt)

### Components
- **HeroCard** - Large daily total display
- **LedgerCard** - Transaction list container
- **TransactionRow** - Individual receipt entry
- **InsightCard** - Spending pattern insights

See `Docs/design.md` for full design specifications.

---

## 🧪 Testing

### Unit Tests
```bash
xcodebuild test -scheme ledger -destination 'platform=iOS Simulator,name=iPhone 16'
```

### UI Tests
Run UI tests from Xcode Test Navigator (⌘+6)

---

## 📝 Development

### Key Files

| File | Purpose |
|------|---------|
| `LedgerApp.swift` | App entry point |
| `AppConfig.swift` | Configuration constants |
| `GoogleAuthManager.swift` | OAuth & token management |
| `GmailClient.swift` | Gmail API integration |
| `ReceiptParser.swift` | Amount extraction |
| `LedgerStore.swift` | Data persistence |
| `HomeView.swift` | Main app interface |

### Data Flow

```
User taps "Sync from Gmail"
  → GoogleAuthManager.getValidAccessToken()
  → GmailClient.getRecentReceipts()
  → ReceiptParser.parse() (confidence scoring)
  → LedgerStore.addTransactions()
  → LedgerStore.syncToWidget()
  → Widget displays updated total
```

---

## 🛠 Configuration

### App Group
- ID: `group.com.taurai.ledger`
- Used for: Widget data sharing

### Keychain Access Groups
- `$(AppIdentifierPrefix)taurai.ledger`

### Bundle Identifiers
- Main App: `taurai.ledger`
- Widget: `taurai.ledger.LedgerWidget`

---

## 📚 Documentation

- [Setup Guide](OAUTH_SETUP_GUIDE.md) - Google OAuth configuration
- [Migration Summary](MIGRATION_SUMMARY.md) - OAuth SDK migration details
- [Quick Start](QUICK_START.md) - 6-minute setup guide
- [Checklist](CHECKLIST.md) - Step-by-step setup checklist
- [Design Specs](Docs/design.md) - UI/UX design system

---

## 🤝 Contributing

This is a personal project, but suggestions and bug reports are welcome via Issues.

---

## 📄 License

[Add your license here]

---

## 🙏 Acknowledgments

- **Google Sign-In SDK** - Official OAuth implementation
- **Gmail API** - Receipt data source
- **SF Symbols** - Apple's icon system

---

## 📧 Contact

[Your contact information]

---

**Built with Claude Code** 🤖
