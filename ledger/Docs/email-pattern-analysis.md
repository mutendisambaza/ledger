# Email Receipt Pattern Analysis

This document contains patterns extracted from real Gmail receipts to improve the parsing pipeline.

## Key Findings from Email Analysis

### Common Receipt Senders

Based on analysis of 25+ emails:

**Ride-Sharing Services:**
- `noreply@uber.com` - Uber receipts
- `no-reply@lyftmail.com` - Lyft receipts

**Banking/Financial:**
- `infoalerts@scotiabank.com` - Bank balance alerts
- `Investec.Life@investec.com` - Financial services

**E-commerce:**
- `mailer@telfar.net` - Shopping receipts
- `ssense@m.ssense.com` - Shopping receipts

### Subject Line Patterns

**Uber:**
- "Your [day] [time of day] trip with Uber"
- "Your Thursday morning trip with Uber"
- "Your Wednesday evening trip with Uber"

**Lyft:**
- "Your ride with [driver name] on [date]"
- "Your ride with Wilson on January 20"

**Banking:**
- "Account balance below specified amount"
- Contains balance information

### Amount Patterns Found

**European Decimal Format (Comma as Decimal Separator):**
- `CA$15,35` - Canadian dollars with comma
- `CA$13,32`
- `CA$11,89`
- `CA$17,09`
- `CA$10,64`
- `CA$1,77`
- `CA$0,46`
- `CA$0,35`
- `CA$0,12`
- `CA$2,26`

**US Decimal Format (Period as Decimal Separator):**
- `$29.99`
- `$150.00`
- `$12.34`

**Currency Codes:**
- `CA$` - Canadian Dollar
- `USD` - US Dollar
- `$` - Generic dollar sign (usually USD)

### Key Phrases for Receipt Detection

**High Confidence Indicators:**
- "Total" followed by amount
- "Trip fare" followed by amount
- "Amount charged"
- "Order total"
- "Grand total"
- "Amount due"
- "Paid"
- "Charged"

**Medium Confidence:**
- "HST" (tax)
- "Payments"
- "Receipt"
- "Invoice"
- "Charge summary"

**Low Confidence (May be discounts/savings):**
- "Save"
- "Discount"
- "Off"
- "Tax" (may refer to tax amount, not total)
- "Tip" (may refer to tip amount, not total)
- "Fee" (may refer to fee amount, not total)
- "Shipping" (may refer to shipping cost, not total)

### Email Body Patterns

**Uber Receipt Structure:**
```
Thanks for riding, [Name]
We hope you enjoyed your ride this [time of day].

Total CA$[amount]
Trip fare CA$[amount]
Estimated insurance and payments costs CA$[amount]
HST CA$[amount]
[Other fees] CA$[amount]

Payments
Visa ••••[last4] ([Bank Name]) CA$[amount] [date] [time]
```

**Key Observations:**
1. "Total" appears before the main amount
2. Multiple amounts present (trip fare, fees, taxes)
3. Need to prioritize "Total" over other amounts
4. European format uses comma as decimal separator
5. Currency code prefix (CA$, USD$) is common

## Improved Regex Patterns

### Pattern 1: Currency Code + Amount (European Format)
```regex
(CA\$|USD\$|EUR\$|GBP\$|CAD\$)\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})
```
Matches: `CA$15,35`, `USD$29.99`

### Pattern 2: Total Label with Amount
```regex
(?:Total|Grand Total|Order Total|Amount Due|Amount Charged|Paid|Charged):\s*(?:CA\$|USD\$|EUR\$|GBP\$|CAD\$|\$)?\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})
```
Matches: `Total CA$15,35`, `Order Total: $29.99`

### Pattern 3: Amount with Currency Suffix
```regex
(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})\s*(USD|CAD|EUR|GBP|CA\$|USD\$)
```
Matches: `15,35 CA$`, `29.99 USD`

### Pattern 4: Generic Dollar Amount (US Format)
```regex
\$?\s*(\d{1,3}(?:,\d{3})*\.\d{2})
```
Matches: `$29.99`, `$1,234.56`

### Pattern 5: Generic Dollar Amount (European Format)
```regex
(?:CA\$|CAD\$)\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})
```
Matches: `CA$15,35`, `CAD$1.234,56`

## Sender-Based Confidence Scoring

**High Confidence Senders (0.8-1.0):**
- `noreply@uber.com` - Always receipts
- `no-reply@lyftmail.com` - Always receipts
- `receipts@[merchant].com` - Usually receipts
- `noreply@[merchant].com` with "receipt" in subject - Usually receipts

**Medium Confidence Senders (0.5-0.7):**
- `infoalerts@scotiabank.com` - May contain balance info
- `mailer@[merchant].com` - Could be marketing or receipt
- E-commerce domains - Could be order confirmations or marketing

**Low Confidence Senders (0.0-0.4):**
- Newsletters
- Social media notifications
- Security alerts
- General notifications

## Subject Line Patterns for Filtering

**Receipt Keywords in Subject:**
- "receipt"
- "trip"
- "order"
- "payment"
- "charge"
- "invoice"
- "confirmation"
- "summary"

**Non-Receipt Keywords (Exclude):**
- "sale"
- "promotion"
- "newsletter"
- "update"
- "alert" (unless from bank)
- "security"

## Recommendations for Parser

1. **Prioritize "Total" keyword** - When multiple amounts found, prefer the one near "Total"
2. **Handle European decimal format** - Support comma as decimal separator
3. **Currency code awareness** - Recognize CA$, USD$, EUR$, etc.
4. **Sender-based filtering** - Use sender domain to boost confidence
5. **Subject line filtering** - Pre-filter emails by subject keywords
6. **Distance-based scoring** - Amounts closer to "Total" keyword score higher
7. **Multiple amount handling** - When multiple amounts found, prefer largest near "Total"

## Example Email Patterns

### Uber Receipt
```
Sender: noreply@uber.com
Subject: Your Thursday morning trip with Uber
Body: ...Total CA$15,35...
Confidence: 0.9 (sender + subject + amount pattern)
```

### Lyft Receipt
```
Sender: no-reply@lyftmail.com
Subject: Your ride with Wilson on January 20
Body: ...Thanks for riding...
Confidence: 0.9 (sender + subject pattern)
```

### Bank Alert
```
Sender: infoalerts@scotiabank.com
Subject: Account balance below specified amount
Body: ...balance has fallen below $100.00...
Confidence: 0.3 (not a purchase receipt, just balance info)
```

## Next Steps

1. Update `AmountPatterns.swift` with European format support
2. Add sender-based confidence scoring to `ReceiptParser.swift`
3. Improve keyword distance calculation
4. Add subject line filtering to `GmailClient.swift`
5. Test with real email samples

