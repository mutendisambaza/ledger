# Accessibility Audit

## Added Labels and Traits

- [x] `HomeView` sync button
  - `.accessibilityLabel("Sync receipts from Gmail")`
  - `.accessibilityHint("Checks your inbox for new receipts")`
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/HomeView.swift`
- [x] `HomeView` hero amount display
  - `.accessibilityLabel("Total spent: ...")`
  - `.accessibilityAddTraits(.updatesFrequently)`
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/HomeView.swift`
- [x] `RestingView` hero amount display
  - `.accessibilityLabel("Today's spending: ...")`
  - `.accessibilityAddTraits(.updatesFrequently)`
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/RestingView.swift`
- [x] `TransactionRow`
  - `.accessibilityLabel("{merchant}, {formattedAmount}, {timeAgo}")`
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/Components/TransactionRow.swift`
- [x] `AmountDisplay`
  - `.accessibilityLabel("Total spent: {formattedAmount}")`
  - `.accessibilityAddTraits(.updatesFrequently)`
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/Components/GlowingText.swift`
- [x] `CalendarNode`
  - `.accessibilityLabel("{date}, {over limit|within limit}, {total} spent")`
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/Components/CalendarNode.swift`
- [x] `CalendarView` calendar node instances
  - Adds explicit per-date label from day totals/limit state
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/CalendarView.swift`
- [x] `TimePeriodToggle` segments
  - `.accessibilityLabel("{period} period")`
  - `.accessibilityValue("Selected"/"Not selected")`
  - File: `/Users/baz/Projects/ledger/ledger/ledger/UI/Components/TimePeriodToggle.swift`

## Sync Behavior Note

- [x] Background sync is still not scheduled in the background for this version.
- [x] Sync is user-triggered in Home and auto-retried on app foreground when a previous network failure set `pending_sync`.
