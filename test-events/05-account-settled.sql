-- ============================================================
-- EVENT: Account Settlement (R3 trigger scenario)
-- Agreement: FRH0000150 (Second charge mortgage, balance £403.37)
-- ============================================================
-- WHAT HAPPENS:
--   1. Final payment of £403.37 brings balance to exactly £0.00
--   2. Transaction INSERT for the final payment
--   3. Agreement UPDATE: balance → 0.00
--   4. Agreement UPDATE: settlement fields set
--      - AgreementSettledFlag → 1
--      - AgreementSettledDate → today
--      - AgreementAutoStatus → 'SETTLED'
--
-- EXPECTED ON KAFKA:
--   Topic: sentinel.SentinelMock.dbo.Transaction → INSERT event (final payment)
--   Topic: sentinel.SentinelMock.dbo.Agreement  → UPDATE event (balance to 0)
--   Topic: sentinel.SentinelMock.dbo.Agreement  → UPDATE event (settlement fields)
--   NOTE: Depending on whether these are in the same DB transaction,
--   Debezium may publish 1, 2, or 3 separate events. This prototype
--   uses separate statements to simulate worst-case correlation scenario.
--
-- TM RELEVANCE:
--   R3 (Account Settled): AgreementSettledFlag changing from 0 to 1
--   triggers an alert. The multi-step write demonstrates why event
--   correlation across topics is needed.
-- ============================================================

USE SentinelMock;
GO

-- Step 1: Insert the final payment transaction
INSERT INTO [Transaction] (
    TransAgreementNumber, TransCreateDate, TransDate,
    TransTypeID, TransNetPayment, TransNetPrincipal,
    TransNetInterest, TransFeesNet, TransBatchNumber
)
VALUES (
    'FRH0000150', GETDATE(), CAST(GETDATE() AS DATE),
    12, 403.37, 390.00,
    13.37, 0, 'DD000110099'
);

PRINT 'Transaction INSERT: Final payment of 403.37 against FRH0000150';

-- Step 2: Update balance to zero (separate commit)
UPDATE Agreement
SET AgreementCurrentBalanceNET = 0.00
WHERE AgreementNumber = 'FRH0000150';

PRINT 'Agreement UPDATE: Balance set to 0.00 for FRH0000150';

-- Step 3: Update settlement fields (separate commit to demonstrate multi-event)
UPDATE Agreement
SET AgreementSettledFlag = 1,
    AgreementSettledDate = CAST(GETDATE() AS DATE),
    AgreementAutoStatus = 'SETTLED'
WHERE AgreementNumber = 'FRH0000150';

PRINT 'Agreement UPDATE: Settlement fields set for FRH0000150';
PRINT 'FRH0000150 is now fully SETTLED.';
GO
