-- ============================================================
-- Seed Data for SentinelMock
-- Realistic test data for 4 agreements covering different scenarios
-- ============================================================

USE SentinelMock;
GO

-- ============================================================
-- AGREEMENT 1: FRH0000291
-- Second charge mortgage, LIVE, on DD, Debt Consolidation
-- ============================================================
INSERT INTO Agreement (
    AgreementNumber, AgreementCustomerNumber, AgreementBorrowers,
    AgreementAgreementDate, AgreementContractEndDate, AgreementNumPayments,
    AgreementPrincipal, AgreementOriginalPrincipal, AgreementCurrentBalanceNET,
    AgreementInstalmentNET, AgreementAutoStatus, AgreementSettledFlag,
    AgreementSettledDate, AgreementPaymentMethod, AgreementAgreementTypeID,
    AgreementPurpose, AgreementFirstPaymentDate, AgreementDueDay,
    AgreementBankSortCode, AgreementBankAccountNumber, AgreementBankAccountName
) VALUES (
    'FRH0000291', 'CUST000291', 'C635824 C635825',
    '2025-12-18', '2040-11-27', 180,
    35000.00, 35000.00, 38375.88,
    382.63, 'LIVE (Primary)', 0,
    NULL, 12, 113,
    'Debt Consolidation', '2026-01-27', 27,
    '20-30-40', '12345678', 'MR J SMITH'
);

-- Custom Profile for FRH0000291 (total incl fees = 403.37)
INSERT INTO CustomProfile (CPAgreement, CPAmount, CPFrequencyType, CPDayOfMonth, CPStartDate, CPOnGoing, CPDeleted, CPRepaymentMethod)
VALUES ('FRH0000291', 403.37, 3, 27, '2026-01-27', 1, 0, 12);

-- Payment Profile for FRH0000291: 3 rows per month (Fee1, Fee2, Pay)
-- Historical months (fallen due)
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-01-27', 4.97, NULL, NULL, 'Fee', 1, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-01-27', 15.77, NULL, NULL, 'Fee', 2, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-01-27', 382.63, 150.00, 232.63, 'Pay', 0, 1);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-02-27', 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-02-27', 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-02-27', 382.63, 152.10, 230.53, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-03-27', 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-03-27', 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-03-27', 382.63, 154.22, 228.41, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-04-27', 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-04-27', 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-04-27', 382.63, 156.37, 226.26, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-05-27', 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-05-27', 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-05-27', 382.63, 158.55, 224.08, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-06-27', 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-06-27', 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000291', '2026-06-27', 382.63, 160.76, 221.87, 'Pay', 0, 0);

-- Historical transactions for FRH0000291 (Jan and Feb payments)
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000291', '2026-01-27 08:30:00', '2026-01-27', 12, 403.37, 150.00, 232.63, 20.74, 'DD000131001');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000291', '2026-02-27 08:30:00', '2026-02-27', 12, 403.37, 152.10, 230.53, 20.74, 'DD000131050');

-- ============================================================
-- AGREEMENT 2: FRM0001544
-- Motor finance, LIVE, on DD, Vehicle Purchase
-- ============================================================
INSERT INTO Agreement (
    AgreementNumber, AgreementCustomerNumber, AgreementBorrowers,
    AgreementAgreementDate, AgreementContractEndDate, AgreementNumPayments,
    AgreementPrincipal, AgreementOriginalPrincipal, AgreementCurrentBalanceNET,
    AgreementInstalmentNET, AgreementAutoStatus, AgreementSettledFlag,
    AgreementSettledDate, AgreementPaymentMethod, AgreementAgreementTypeID,
    AgreementPurpose, AgreementFirstPaymentDate, AgreementDueDay,
    AgreementBankSortCode, AgreementBankAccountNumber, AgreementBankAccountName
) VALUES (
    'FRM0001544', 'CUST001544', 'C712001',
    '2025-06-15', '2030-06-15', 60,
    12000.00, 12000.00, 10250.00,
    215.00, 'LIVE (Primary)', 0,
    NULL, 12, 205,
    'Vehicle Purchase', '2025-07-15', 15,
    '40-50-60', '87654321', 'MS A JONES'
);

-- Payment Profile for FRM0001544: 3 rows per month
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-07-15', 3.50, NULL, NULL, 'Fee', 1, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-07-15', 11.50, NULL, NULL, 'Fee', 2, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-07-15', 215.00, 155.00, 60.00, 'Pay', 0, 1);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-08-15', 3.50, NULL, NULL, 'Fee', 1, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-08-15', 11.50, NULL, NULL, 'Fee', 2, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-08-15', 215.00, 156.00, 59.00, 'Pay', 0, 1);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-09-15', 3.50, NULL, NULL, 'Fee', 1, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-09-15', 11.50, NULL, NULL, 'Fee', 2, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2025-09-15', 215.00, 157.00, 58.00, 'Pay', 0, 1);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-03-15', 3.50, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-03-15', 11.50, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-03-15', 215.00, 161.00, 54.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-04-15', 3.50, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-04-15', 11.50, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-04-15', 215.00, 162.00, 53.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-05-15', 3.50, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-05-15', 11.50, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-05-15', 215.00, 163.00, 52.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-06-15', 3.50, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-06-15', 11.50, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-06-15', 215.00, 164.00, 51.00, 'Pay', 0, 0);

INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-07-15', 3.50, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-07-15', 11.50, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRM0001544', '2026-07-15', 215.00, 165.00, 50.00, 'Pay', 0, 0);

-- Historical transactions for FRM0001544 (8 monthly DD payments)
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2025-07-15 08:00:00', '2025-07-15', 12, 230.00, 155.00, 60.00, 15.00, 'DD000120001');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2025-08-15 08:00:00', '2025-08-15', 12, 230.00, 156.00, 59.00, 15.00, 'DD000120010');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2025-09-15 08:00:00', '2025-09-15', 12, 230.00, 157.00, 58.00, 15.00, 'DD000120020');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2025-10-15 08:00:00', '2025-10-15', 12, 230.00, 158.00, 57.00, 15.00, 'DD000120030');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2025-11-15 08:00:00', '2025-11-15', 12, 230.00, 159.00, 56.00, 15.00, 'DD000120040');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2025-12-15 08:00:00', '2025-12-15', 12, 230.00, 160.00, 55.00, 15.00, 'DD000120050');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2026-01-15 08:00:00', '2026-01-15', 12, 230.00, 161.00, 54.00, 15.00, 'DD000120060');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRM0001544', '2026-02-15 08:00:00', '2026-02-15', 12, 230.00, 162.00, 53.00, 15.00, 'DD000120070');

-- ============================================================
-- AGREEMENT 3: FRP0002871
-- Personal loan, LIVE, on CARD PAYMENT (not DD)
-- ============================================================
INSERT INTO Agreement (
    AgreementNumber, AgreementCustomerNumber, AgreementBorrowers,
    AgreementAgreementDate, AgreementContractEndDate, AgreementNumPayments,
    AgreementPrincipal, AgreementOriginalPrincipal, AgreementCurrentBalanceNET,
    AgreementInstalmentNET, AgreementAutoStatus, AgreementSettledFlag,
    AgreementSettledDate, AgreementPaymentMethod, AgreementAgreementTypeID,
    AgreementPurpose, AgreementFirstPaymentDate, AgreementDueDay,
    AgreementBankSortCode, AgreementBankAccountNumber, AgreementBankAccountName
) VALUES (
    'FRP0002871', 'CUST002871', 'C845300',
    '2025-09-01', '2028-09-01', 36,
    5000.00, 5000.00, 3800.00,
    155.00, 'LIVE (Primary)', 0,
    NULL, 8, 301,
    'Home Improvement', '2025-10-01', 1,
    NULL, NULL, NULL
);

-- Payment Profile for FRP0002871 (no fees, just Pay rows)
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2025-10-01', 155.00, 120.00, 35.00, 'Pay', 0, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2025-11-01', 155.00, 121.00, 34.00, 'Pay', 0, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2025-12-01', 155.00, 122.00, 33.00, 'Pay', 0, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2026-01-01', 155.00, 123.00, 32.00, 'Pay', 0, 1);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2026-02-01', 155.00, 124.00, 31.00, 'Pay', 0, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2026-03-01', 155.00, 125.00, 30.00, 'Pay', 0, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2026-04-01', 155.00, 126.00, 29.00, 'Pay', 0, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2026-05-01', 155.00, 127.00, 28.00, 'Pay', 0, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2026-06-01', 155.00, 128.00, 27.00, 'Pay', 0, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRP0002871', '2026-07-01', 155.00, 129.00, 26.00, 'Pay', 0, 0);

-- Historical transactions for FRP0002871 (4 card payments)
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransReference)
VALUES ('FRP0002871', '2025-10-01 14:22:00', '2025-10-01', 32, 155.00, 120.00, 35.00, 0, 'CARD-TXN-90001');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransReference)
VALUES ('FRP0002871', '2025-11-01 10:15:00', '2025-11-01', 32, 155.00, 121.00, 34.00, 0, 'CARD-TXN-90002');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransReference)
VALUES ('FRP0002871', '2025-12-01 16:45:00', '2025-12-01', 32, 155.00, 122.00, 33.00, 0, 'CARD-TXN-90003');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransReference)
VALUES ('FRP0002871', '2026-01-02 09:30:00', '2026-01-02', 32, 155.00, 123.00, 32.00, 0, 'CARD-TXN-90004');

-- ============================================================
-- AGREEMENT 4: FRH0000150
-- Second charge mortgage, nearly settled (one payment away)
-- ============================================================
INSERT INTO Agreement (
    AgreementNumber, AgreementCustomerNumber, AgreementBorrowers,
    AgreementAgreementDate, AgreementContractEndDate, AgreementNumPayments,
    AgreementPrincipal, AgreementOriginalPrincipal, AgreementCurrentBalanceNET,
    AgreementInstalmentNET, AgreementAutoStatus, AgreementSettledFlag,
    AgreementSettledDate, AgreementPaymentMethod, AgreementAgreementTypeID,
    AgreementPurpose, AgreementFirstPaymentDate, AgreementDueDay,
    AgreementBankSortCode, AgreementBankAccountNumber, AgreementBankAccountName
) VALUES (
    'FRH0000150', 'CUST000150', 'C501200',
    '2025-07-01', '2027-07-01', 24,
    8000.00, 8000.00, 403.37,
    380.00, 'LIVE (Primary)', 0,
    NULL, 12, 113,
    'Debt Consolidation', '2025-08-01', 1,
    '10-20-30', '11223344', 'MR B WILLIAMS'
);

-- Custom Profile for FRH0000150
INSERT INTO CustomProfile (CPAgreement, CPAmount, CPFrequencyType, CPDayOfMonth, CPStartDate, CPOnGoing, CPDeleted, CPRepaymentMethod)
VALUES ('FRH0000150', 403.37, 3, 1, '2025-08-01', 1, 0, 12);

-- Payment Profile for FRH0000150 (remaining payments)
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000150', '2026-03-01', 4.97, NULL, NULL, 'Fee', 1, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000150', '2026-03-01', 15.77, NULL, NULL, 'Fee', 2, 0);
INSERT INTO PaymentProfile (PayProAgreementNumber, PayProDate, PayProNetAmount, PayProPrincipal, PayProInterest, PayProType, PayProFeeOrInsID, PayProFallenDue)
VALUES ('FRH0000150', '2026-03-01', 380.00, 370.00, 10.00, 'Pay', 0, 0);

-- Historical transactions for FRH0000150 (7 monthly payments already made)
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000150', '2025-08-01 08:00:00', '2025-08-01', 12, 403.37, 340.00, 42.63, 20.74, 'DD000110001');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000150', '2025-09-01 08:00:00', '2025-09-01', 12, 403.37, 344.00, 38.63, 20.74, 'DD000110010');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000150', '2025-10-01 08:00:00', '2025-10-01', 12, 403.37, 348.00, 34.63, 20.74, 'DD000110020');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000150', '2025-11-01 08:00:00', '2025-11-01', 12, 403.37, 352.00, 30.63, 20.74, 'DD000110030');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000150', '2025-12-01 08:00:00', '2025-12-01', 12, 403.37, 356.00, 26.63, 20.74, 'DD000110040');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000150', '2026-01-01 08:00:00', '2026-01-01', 12, 403.37, 360.00, 22.63, 20.74, 'DD000110050');
INSERT INTO [Transaction] (TransAgreementNumber, TransCreateDate, TransDate, TransTypeID, TransNetPayment, TransNetPrincipal, TransNetInterest, TransFeesNet, TransBatchNumber)
VALUES ('FRH0000150', '2026-02-01 08:00:00', '2026-02-01', 12, 403.37, 364.00, 18.63, 20.74, 'DD000110060');

PRINT 'Seed data inserted successfully for all 4 agreements.';
GO
