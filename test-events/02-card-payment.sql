-- ============================================================
-- EVENT: Card Payment on non-DD account
-- Agreement: FRP0002871 (Personal loan, pays by card)
-- ============================================================
-- WHAT HAPPENS:
--   1. Customer makes their monthly card payment of £155.00
--   2. Transaction INSERT with TransTypeID = 32 (Card Payment)
--   3. Agreement balance reduced
--
-- EXPECTED ON KAFKA:
--   Topic: sentinel.SentinelMock.dbo.Transaction → INSERT event
--   Topic: sentinel.SentinelMock.dbo.Agreement  → UPDATE event
--
-- TM RELEVANCE:
--   Normal scheduled payment via card. Amount matches expected
--   instalment from Payment Profile (no Custom Profile exists).
--   AgreementPaymentMethod = 8 (Card), not 12 (DD).
-- ============================================================

USE SentinelMock;
GO

-- Step 1: Insert the card payment transaction
INSERT INTO [Transaction] (
    TransAgreementNumber, TransCreateDate, TransDate,
    TransTypeID, TransNetPayment, TransNetPrincipal,
    TransNetInterest, TransFeesNet, TransReference
)
VALUES (
    'FRP0002871', GETDATE(), CAST(GETDATE() AS DATE),
    32, 155.00, 125.00,
    30.00, 0, 'CARD-TXN-90005'
);

PRINT 'Transaction INSERT: Card payment of 155.00 against FRP0002871';

-- Step 2: Update the agreement balance
UPDATE Agreement
SET AgreementCurrentBalanceNET = AgreementCurrentBalanceNET - 155.00
WHERE AgreementNumber = 'FRP0002871';

PRINT 'Agreement UPDATE: Balance reduced by 155.00 for FRP0002871';
GO
