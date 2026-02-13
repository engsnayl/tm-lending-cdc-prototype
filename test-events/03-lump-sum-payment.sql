-- ============================================================
-- EVENT: Lump Sum Overpayment (R1/R2 trigger scenario)
-- Agreement: FRM0001544 (Motor finance, expected ~£230/month)
-- ============================================================
-- WHAT HAPPENS:
--   1. Customer makes a £5,000 card payment against a motor
--      finance agreement where the expected monthly is ~£230
--   2. This is 21x the expected payment amount
--   3. Transaction INSERT with TransTypeID = 32 (Card Payment)
--   4. Agreement balance reduced significantly
--
-- EXPECTED ON KAFKA:
--   Topic: sentinel.SentinelMock.dbo.Transaction → INSERT event
--   Topic: sentinel.SentinelMock.dbo.Agreement  → UPDATE event
--
-- TM RELEVANCE:
--   R1 (Overpayment): Payment £5,000 vs expected £230 = 2,074% of expected
--   R2 (Lump Sum): Absolute threshold likely exceeded
--   Both rules should flag this for investigation.
--   Expected amount comes from PaymentProfile (no Custom Profile for this agreement):
--     Fee1 £3.50 + Fee2 £11.50 + Pay £215.00 = £230.00 total
-- ============================================================

USE SentinelMock;
GO

-- Step 1: Insert the large card payment
INSERT INTO [Transaction] (
    TransAgreementNumber, TransCreateDate, TransDate,
    TransTypeID, TransNetPayment, TransNetPrincipal,
    TransNetInterest, TransFeesNet, TransReference
)
VALUES (
    'FRM0001544', GETDATE(), CAST(GETDATE() AS DATE),
    32, 5000.00, 4800.00,
    200.00, 0, 'CARD-TXN-LUMP-001'
);

PRINT 'Transaction INSERT: LUMP SUM card payment of 5000.00 against FRM0001544';
PRINT 'Expected monthly payment is ~230.00 - this is 21x the expected amount';

-- Step 2: Update the agreement balance
UPDATE Agreement
SET AgreementCurrentBalanceNET = AgreementCurrentBalanceNET - 5000.00
WHERE AgreementNumber = 'FRM0001544';

PRINT 'Agreement UPDATE: Balance reduced by 5000.00 for FRM0001544';
GO
