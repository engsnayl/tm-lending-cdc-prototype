-- ============================================================
-- EVENT: Customer Refund Issued (R5 trigger scenario)
-- Agreement: FRM0001544 (Motor finance)
-- ============================================================
-- WHAT HAPPENS:
--   1. A refund of £215.00 is issued to the customer
--   2. Transaction INSERT with TransTypeID = 3 (Refund)
--   3. Agreement balance INCREASES (money going back to customer)
--
-- EXPECTED ON KAFKA:
--   Topic: sentinel.SentinelMock.dbo.Transaction → INSERT event
--   Topic: sentinel.SentinelMock.dbo.Agreement  → UPDATE event (balance INCREASES)
--
-- TM RELEVANCE:
--   R5 (Refund): ANY refund transaction triggers an alert
--   Refund TransTypeIDs for Secured platform: 3, 107, 108, 112
--   Refund TransTypeIDs for Unsecured platform: 1003, 1100, 1108, 1109,
--     1205, 1206, 1207, 1208, 1210, 1308
--   The balance going UP instead of DOWN is the key indicator.
-- ============================================================

USE SentinelMock;
GO

-- Step 1: Insert the refund transaction (note: positive amount means refund TO customer)
INSERT INTO [Transaction] (
    TransAgreementNumber, TransCreateDate, TransDate,
    TransTypeID, TransNetPayment, TransNetPrincipal,
    TransNetInterest, TransFeesNet, TransReference
)
VALUES (
    'FRM0001544', GETDATE(), CAST(GETDATE() AS DATE),
    3, 215.00, 200.00,
    15.00, 0, 'REFUND-001'
);

PRINT 'Transaction INSERT: REFUND of 215.00 against FRM0001544';

-- Step 2: Update the agreement balance (INCREASES for refund)
UPDATE Agreement
SET AgreementCurrentBalanceNET = AgreementCurrentBalanceNET + 215.00
WHERE AgreementNumber = 'FRM0001544';

PRINT 'Agreement UPDATE: Balance INCREASED by 215.00 for FRM0001544 (refund)';
GO
