-- ============================================================
-- EVENT: New Account Opened (Agreement funded)
-- Agreement: FRH0000400 (brand new second charge mortgage)
-- ============================================================
-- WHAT HAPPENS:
--   1. New agreement accepted from Proposal into Sentinel Admin
--   2. Agreement INSERT with all initial fields
--   3. Payment Profile INSERT (multiple rows for scheduled payments)
--   4. Custom Profile INSERT (if non-standard payment amount)
--
-- EXPECTED ON KAFKA:
--   Topic: sentinel.SentinelMock.dbo.Agreement → INSERT event (new agreement)
--   NOTE: PaymentProfile and CustomProfile tables do NOT have CDC
--   enabled, so those inserts will NOT appear on Kafka topics.
--   Only the Agreement insert will be captured.
--
-- TM RELEVANCE:
--   R4 (New Account): New Agreement INSERT triggers identity check.
--   The downstream consumer (Ledger/Identity) needs to build
--   the customer profile from this initial data.
-- ============================================================

USE SentinelMock;
GO

-- Step 1: Insert the new agreement
INSERT INTO Agreement (
    AgreementNumber, AgreementCustomerNumber, AgreementBorrowers,
    AgreementAgreementDate, AgreementContractEndDate, AgreementNumPayments,
    AgreementPrincipal, AgreementOriginalPrincipal, AgreementCurrentBalanceNET,
    AgreementInstalmentNET, AgreementAutoStatus, AgreementSettledFlag,
    AgreementSettledDate, AgreementPaymentMethod, AgreementAgreementTypeID,
    AgreementPurpose, AgreementFirstPaymentDate, AgreementDueDay,
    AgreementBankSortCode, AgreementBankAccountNumber, AgreementBankAccountName
) VALUES (
    'FRH0000400', 'CUST000400', 'C900100 C900101',
    CAST(GETDATE() AS DATE), DATEADD(YEAR, 10, GETDATE()), 120,
    25000.00, 25000.00, 25000.00,
    295.00, 'LIVE (Primary)', 0,
    NULL, 12, 113,
    'Home Improvement', DATEADD(MONTH, 1, GETDATE()), 15,
    '30-40-50', '99887766', 'MRS C TAYLOR'
);

PRINT 'Agreement INSERT: New agreement FRH0000400 created';

-- Step 2: Insert Payment Profile rows (these won't appear on Kafka - no CDC)
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)), 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)), 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)), 295.00, 170.00, 125.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 2, CAST(GETDATE() AS DATE)), 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 2, CAST(GETDATE() AS DATE)), 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 2, CAST(GETDATE() AS DATE)), 295.00, 172.00, 123.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 3, CAST(GETDATE() AS DATE)), 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 3, CAST(GETDATE() AS DATE)), 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 3, CAST(GETDATE() AS DATE)), 295.00, 174.00, 121.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 4, CAST(GETDATE() AS DATE)), 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 4, CAST(GETDATE() AS DATE)), 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 4, CAST(GETDATE() AS DATE)), 295.00, 176.00, 119.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 5, CAST(GETDATE() AS DATE)), 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 5, CAST(GETDATE() AS DATE)), 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 5, CAST(GETDATE() AS DATE)), 295.00, 178.00, 117.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 6, CAST(GETDATE() AS DATE)), 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 6, CAST(GETDATE() AS DATE)), 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000400', DATEADD(MONTH, 6, CAST(GETDATE() AS DATE)), 295.00, 180.00, 115.00, 'Pay', 0, 0);

PRINT 'Payment Profile rows inserted for FRH0000400 (6 months)';

-- Step 3: Insert Custom Profile (simulates the delayed creation scenario)
INSERT INTO CustomProfile (CPAgreement, CPAmount, CPFrequencyType, CPDayOfMonth, CPStartDate, CPOnGoing, CPDeleted, CPRepaymentMethod)
VALUES ('FRH0000400', 315.74, 3, 15, DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)), 1, 0, 12);

PRINT 'Custom Profile created for FRH0000400: total payment = 315.74';
PRINT 'New agreement FRH0000400 is now LIVE.';
GO
