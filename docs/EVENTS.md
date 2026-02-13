# Business Events

This document describes the four business events simulated by this prototype, their CDC trigger logic, database write sequences, and edge cases.

## Event 1: Payment Received

**Test script**: `test-events/01-payment-received.sql` (DD), `test-events/02-card-payment.sql` (Card)

### What Happens in Sentinel
1. A scheduled payment (DD or card) is processed
2. Sentinel inserts a row into the `Transaction` table
3. Sentinel updates the `Agreement.AgreementCurrentBalanceNET` (balance decreases)

### Database Write Sequence
```
INSERT → Transaction (new payment row)
UPDATE → Agreement  (balance reduced)
```

### CDC Events Produced
| Order | Topic | Operation | Key Fields |
|-------|-------|-----------|------------|
| 1 | sentinel...dbo.Transaction | INSERT (op=c) | TransTypeID, TransNetPayment, TransAgreementNumber |
| 2 | sentinel...dbo.Agreement | UPDATE (op=u) | AgreementCurrentBalanceNET (before/after) |

### TM Rule Relevance
- **R1 (Overpayment %)**: Compare `TransNetPayment` against expected payment amount
- **R2 (Lump Sum)**: Check if `TransNetPayment` exceeds absolute threshold

### Expected Payment Lookup Hierarchy
To determine the "expected" payment amount for R1/R2:
1. **Check CustomProfile first**: If `CPAgreement` exists AND `CPOnGoing = 1` AND `CPDeleted = 0` → use `CPAmount`
2. **Fall back to PaymentProfile**: Sum all `PayProNetAmount` where `PayProDate` matches the current payment period and `PayProFallenDue = 0`
   - This includes rows where `PayProType = 'Pay'` AND `PayProType = 'Fee'`
   - Total = Pay row + Fee1 row + Fee2 row

### Edge Cases
- Payment may arrive on a different day than `AgreementDueDay`
- Card payments (TransTypeID=32) may be processed at any time, not on a schedule
- The two SQL statements (INSERT + UPDATE) may be separate database commits, producing separate Kafka events with different timestamps

---

## Event 2: Refund Issued (R5)

**Test script**: `test-events/04-refund-issued.sql`

### What Happens in Sentinel
1. A refund is issued to the customer
2. Sentinel inserts a row into the `Transaction` table with a refund TransTypeID
3. Sentinel updates the `Agreement.AgreementCurrentBalanceNET` (balance **increases**)

### Database Write Sequence
```
INSERT → Transaction (refund row, balance goes UP)
UPDATE → Agreement  (balance increased)
```

### CDC Events Produced
| Order | Topic | Operation | Key Fields |
|-------|-------|-----------|------------|
| 1 | sentinel...dbo.Transaction | INSERT (op=c) | TransTypeID (refund code), TransNetPayment |
| 2 | sentinel...dbo.Agreement | UPDATE (op=u) | AgreementCurrentBalanceNET (increases) |

### TM Rule Relevance
- **R5 (Refund)**: ANY transaction with a refund TransTypeID triggers an alert

### Refund Transaction Type Codes

**Secured Platform (FKPlatformID = 1)**:
| TransTypeID | Description |
|-------------|-------------|
| 3 | Refund |
| 107 | Refund of Card Payment |
| 108 | Refund of Direct Debit |
| 112 | Refund of OTP |

**Unsecured Platform (FKPlatformID = 2)**:
| TransTypeID | Description |
|-------------|-------------|
| 1003 | Refund |
| 1100 | Refund DM |
| 1108 | Refund of Card Payment |
| 1109 | Refund of Direct Debit |
| 1205 | Chequebase Live Refund |
| 1206 | Transfer Refund |
| 1207 | Cheque Refund |
| 1208 | Cash Refund |
| 1210 | Terminal Refund |
| 1308 | Refund |

### Edge Cases
- Refund TransTypeIDs differ between secured and unsecured platforms
- The downstream system must maintain a lookup of ALL valid refund codes
- Balance moving upward is the key signal (but should not be the sole trigger — use TransTypeID)

---

## Event 3: Account Settled (R3)

**Test script**: `test-events/05-account-settled.sql`

### What Happens in Sentinel
1. The final payment brings the balance to zero
2. Sentinel inserts the final payment transaction
3. Sentinel updates the agreement balance to 0.00
4. Sentinel sets settlement fields: `AgreementSettledFlag = 1`, `AgreementSettledDate`, `AgreementAutoStatus = 'SETTLED'`

### Database Write Sequence
```
INSERT → Transaction  (final payment)
UPDATE → Agreement   (balance → 0.00)
UPDATE → Agreement   (settled flag, date, status)
```

The two Agreement updates may or may not be in the same database transaction. This prototype executes them as **separate statements** to demonstrate the worst-case scenario.

### CDC Events Produced
| Order | Topic | Operation | Key Fields |
|-------|-------|-----------|------------|
| 1 | sentinel...dbo.Transaction | INSERT (op=c) | Final payment amount |
| 2 | sentinel...dbo.Agreement | UPDATE (op=u) | AgreementCurrentBalanceNET → 0.00 |
| 3 | sentinel...dbo.Agreement | UPDATE (op=u) | AgreementSettledFlag 0→1, AgreementAutoStatus→'SETTLED' |

### TM Rule Relevance
- **R3 (Account Settled)**: `AgreementSettledFlag` changing from 0 to 1 triggers the rule
- The Debezium event `before.AgreementSettledFlag = 0` and `after.AgreementSettledFlag = 1` is the definitive signal

### Edge Cases
- Settlement may produce 2 or 3 separate Kafka events depending on transaction boundaries
- The balance update and settlement flag update may arrive as separate events, requiring correlation
- `AgreementAutoStatus` changing to 'SETTLED' is informational; the flag is the definitive trigger

---

## Event 4: Account Opened (R4)

**Test script**: `test-events/06-account-opened.sql`

### What Happens in Sentinel
1. A new loan is accepted from Proposal into Sentinel Admin
2. Sentinel inserts a new row into the `Agreement` table
3. Sentinel inserts Payment Profile rows (scheduled payment breakdown)
4. Sentinel may insert a Custom Profile row (optional, sometimes delayed)

### Database Write Sequence
```
INSERT → Agreement       (new agreement record)
INSERT → PaymentProfile  (multiple rows — NOT CDC-enabled)
INSERT → CustomProfile   (optional — NOT CDC-enabled)
```

### CDC Events Produced
| Order | Topic | Operation | Key Fields |
|-------|-------|-----------|------------|
| 1 | sentinel...dbo.Agreement | INSERT (op=c) | All agreement fields |

**Important**: Only the Agreement INSERT appears on Kafka. PaymentProfile and CustomProfile tables do NOT have CDC enabled, so their inserts are invisible to the CDC pipeline.

### TM Rule Relevance
- **R4 (New Account)**: New Agreement INSERT triggers identity verification
- Downstream systems need to build customer profiles from `AgreementCustomerNumber` and `AgreementBorrowers`

### Edge Cases
- Custom Profile creation may be delayed (not in the same batch as Agreement INSERT)
- `AgreementBorrowers` contains space-delimited IDs that need parsing (e.g., `'C635824 C635825'`)
- `AgreementCustomerNumber` is per-agreement, NOT a global customer ID
- Payment Profile and Custom Profile data must be fetched via direct SQL query, not CDC events
