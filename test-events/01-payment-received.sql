-- ============================================================
-- EVENT: Payment Received (Scheduled DD)
-- Agreement: FRH0000291 (Second charge mortgage)
-- ============================================================
-- WHAT HAPPENS:
--   1. Monthly DD payment of £403.37 lands against FRH0000291
--   2. Transaction INSERT recorded in the Transaction table
--   3. Agreement balance reduced by the payment amount
--
-- EXPECTED ON KAFKA:
--   Topic: sentinel.SentinelMock.dbo.Transaction → INSERT event
--   Topic: sentinel.SentinelMock.dbo.Agreement  → UPDATE event (balance decreases)
--
-- TM RELEVANCE:
--   This is a normal scheduled payment. R1/R2 rules compare this
--   against the expected payment amount (Custom Profile or Payment Profile).
--   £403.37 matches the Custom Profile amount, so no alert expected.
-- ============================================================

USE SentinelMock;
GO

-- Step 1: Insert the transaction (Sentinel does this first)
INSERT INTO [Transaction] (
    TransAgreementNumber, TransCreateDate, TransDate,
    TransTypeID, TransNetPayment, TransNetPrincipal,
    TransNetInterest, TransFeesNet, TransBatchNumber
)
VALUES (
    'FRH0000291', GETDATE(), CAST(GETDATE() AS DATE),
    12, 403.37, 154.11,
    249.26, 0, 'DD000131099'
);

PRINT 'Transaction INSERT: DD payment of 403.37 against FRH0000291';

-- Step 2: Update the agreement balance (follows the transaction)
UPDATE Agreement
SET AgreementCurrentBalanceNET = AgreementCurrentBalanceNET - 403.37
WHERE AgreementNumber = 'FRH0000291';

PRINT 'Agreement UPDATE: Balance reduced by 403.37 for FRH0000291';
GO
