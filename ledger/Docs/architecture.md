# Ledger Architecture

## Overview

Ledger is a passive financial observer that reconstructs spending from Gmail receipts. It follows a 4-layer architecture:

```
Signal Layer (Gmail API) 
    ↓
Intelligence Layer (Receipt Parser)
    ↓
Memory Layer (LedgerStore + App Group)
    ↓
Interface Layer (App + Lock Screen Widget)
```

## Phase 1: Foundation

Phase 1 establishes the core data models and storage infrastructure:

### Components

1. **AppConfig** - Centralized configuration and constants
2. **Models** - Transaction and DailySummary data structures
3. **LedgerStore** - JSON persistence with App Group sync
4. **WidgetStoreReader** - Safe App Group access for widgets
5. **Lock Screen Widget** - Placeholder display showing $0.00

### Data Flow

1. App writes to `LedgerStore`
2. `LedgerStore.syncToWidget()` writes to App Group UserDefaults
3. Widget reads via `WidgetStoreReader`
4. Widget displays formatted amount

### App Group

- Identifier: `group.com.taurai.ledger`
- Shared keys:
  - `today_total_cents` (Int)
  - `last_updated_iso` (String)
  - `today_date_iso` (String)

## Future Phases

- **Phase 2**: Gmail API integration
- **Phase 3**: Receipt parsing intelligence
- **Phase 4**: Background sync and updates

