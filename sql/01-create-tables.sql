-- ============================================================
-- SentinelMock Database Schema
-- Mock of the Aryza Sentinel lending management system
-- Subset of real tables: Agreement (269 cols), Transaction (55 cols)
-- Only fields relevant to Transaction Monitoring rules included
-- ============================================================

CREATE DATABASE SentinelMock;
GO

USE SentinelMock;
GO

-- ------------------------------------------------------------
-- TransactionType: Reference table for transaction type lookups
-- Used to classify payments, refunds, and other movements
-- ------------------------------------------------------------
CREATE TABLE TransactionType (
    TransactionTypeID         INT            PRIMARY KEY,
    FKPlatformID              INT            NOT NULL,        -- 1 = Secured, 2 = Unsecured
    Description               VARCHAR(100)   NOT NULL
);
GO

-- Secured platform (1) - Payment types
INSERT INTO TransactionType VALUES (12, 1, 'Direct Debit');
INSERT INTO TransactionType VALUES (32, 1, 'Card Payment');
INSERT INTO TransactionType VALUES (7, 1, 'Bank Transfer');

-- Secured platform (1) - Refund types (R5 trigger)
INSERT INTO TransactionType VALUES (3, 1, 'Refund');
INSERT INTO TransactionType VALUES (107, 1, 'Refund of Card Payment');
INSERT INTO TransactionType VALUES (108, 1, 'Refund of Direct Debit');
INSERT INTO TransactionType VALUES (112, 1, 'Refund of OTP');

-- Unsecured platform (2) - Payment types
INSERT INTO TransactionType VALUES (1012, 2, 'Direct Debit');
INSERT INTO TransactionType VALUES (1032, 2, 'Card Payment');

-- Unsecured platform (2) - Refund types (R5 trigger)
INSERT INTO TransactionType VALUES (1003, 2, 'Refund');
INSERT INTO TransactionType VALUES (1100, 2, 'Refund DM');
INSERT INTO TransactionType VALUES (1108, 2, 'Refund of Card Payment');
INSERT INTO TransactionType VALUES (1109, 2, 'Refund of Direct Debit');
INSERT INTO TransactionType VALUES (1205, 2, 'Chequebase Live Refund');
INSERT INTO TransactionType VALUES (1206, 2, 'Transfer Refund');
INSERT INTO TransactionType VALUES (1207, 2, 'Cheque Refund');
INSERT INTO TransactionType VALUES (1208, 2, 'Cash Refund');
INSERT INTO TransactionType VALUES (1210, 2, 'Terminal Refund');
INSERT INTO TransactionType VALUES (1308, 2, 'Refund');

-- Non-TM types (should be ignored by monitoring)
INSERT INTO TransactionType VALUES (50, 1, 'Write Off');
INSERT INTO TransactionType VALUES (60, 1, 'Goodwill');
INSERT INTO TransactionType VALUES (70, 1, 'Adjustment');
GO

-- ------------------------------------------------------------
-- Agreement: Core loan/mortgage agreement record
-- Real Sentinel table has 269 columns; this is the TM subset
-- ------------------------------------------------------------
CREATE TABLE Agreement (
    AgreementNumber           VARCHAR(20)    PRIMARY KEY,     -- e.g. 'FRH0000291'
    AgreementCustomerNumber   VARCHAR(20)    NOT NULL,        -- Sentinel customer ID (per-agreement, NOT global)
    AgreementBorrowers        VARCHAR(100)   NULL,            -- Space-delimited borrower IDs e.g. 'C635824 C635825'
    AgreementAgreementDate    DATE           NOT NULL,        -- Loan funding date
    AgreementContractEndDate  DATE           NULL,            -- Expected maturity date
    AgreementNumPayments      INT            NULL,            -- Term in months (e.g. 180 for 15yr mortgage)
    AgreementPrincipal        DECIMAL(18,2)  NOT NULL,        -- Original loan amount
    AgreementOriginalPrincipal DECIMAL(18,2) NULL,            -- Should match AgreementPrincipal initially
    AgreementCurrentBalanceNET DECIMAL(18,2) NOT NULL,        -- Current outstanding balance
    AgreementInstalmentNET    DECIMAL(18,2)  NULL,            -- Base monthly instalment EXCLUDING fees
    AgreementAutoStatus       VARCHAR(50)    NOT NULL,        -- e.g. 'LIVE (Primary)', 'SETTLED'
    AgreementSettledFlag      BIT            NOT NULL DEFAULT 0, -- 0 = not settled, 1 = settled
    AgreementSettledDate      DATE           NULL,            -- NULL until settled, then the settlement date
    AgreementPaymentMethod    INT            NOT NULL,        -- 12 = Direct Debit
    AgreementAgreementTypeID  INT            NOT NULL,        -- Product type code (e.g. 113)
    AgreementPurpose          VARCHAR(100)   NULL,            -- e.g. 'Debt Consolidation'
    AgreementFirstPaymentDate DATE           NULL,
    AgreementDueDay           INT            NULL,            -- Day of month payment due (e.g. 1)
    AgreementBankSortCode     VARCHAR(10)    NULL,            -- Customer's DD sort code
    AgreementBankAccountNumber VARCHAR(20)   NULL,            -- Customer's DD account number
    AgreementBankAccountName  VARCHAR(100)   NULL             -- Name on customer's bank account
);
GO

-- ------------------------------------------------------------
-- Transaction: Individual financial movements against agreements
-- Real Sentinel table has 55 columns; this is the TM subset
-- TransCounter starts high to look like real production data
-- ------------------------------------------------------------
CREATE TABLE [Transaction] (
    TransCounter              INT            PRIMARY KEY IDENTITY(9924770, 1),
    TransAgreementNumber      VARCHAR(20)    NOT NULL REFERENCES Agreement(AgreementNumber),
    TransCreateDate           DATETIME       NOT NULL,
    TransDate                 DATE           NOT NULL,
    TransTypeID               INT            NOT NULL,
    TransNetPayment           DECIMAL(18,2)  NOT NULL,        -- Pre-summed total (principal + interest + fees)
    TransNetPrincipal         DECIMAL(18,2)  NOT NULL,        -- Principal component
    TransNetInterest          DECIMAL(18,2)  NOT NULL,        -- Interest component
    TransFeesNet              DECIMAL(18,2)  NOT NULL DEFAULT 0, -- Fees component
    TransReference            VARCHAR(100)   NULL,            -- External reference / UUID
    TransBatchNumber          VARCHAR(20)    NULL,            -- Batch reference
    TransCurrencyCode         VARCHAR(10)    NULL,            -- NOT POPULATED in real Sentinel (R7 gap)
    TransBankID               INT            NULL DEFAULT 0   -- NOT POPULATED in real Sentinel (R6 gap)
);
GO

-- ------------------------------------------------------------
-- PaymentProfile: Scheduled payment breakdown per agreement
-- Shows what payments are expected and when
-- ------------------------------------------------------------
CREATE TABLE PaymentProfile (
    PayProID                  INT            PRIMARY KEY IDENTITY(1,1),
    PayProAgreementNumber     VARCHAR(20)    NOT NULL REFERENCES Agreement(AgreementNumber),
    PayProDate                DATE           NOT NULL,        -- Scheduled payment date
    PayProNetAmount           DECIMAL(18,2)  NOT NULL,        -- Amount for this row
    PayProPrincipal           DECIMAL(18,2)  NULL,
    PayProInterest            DECIMAL(18,2)  NULL,
    PayProType                VARCHAR(10)    NOT NULL,        -- 'Pay' or 'Fee'
    PayProFeeOrInsID          INT            NOT NULL,        -- 0 = principal+interest, 1 = fee type 1, 2 = fee type 2
    PayProFallenDue           BIT            NOT NULL DEFAULT 0  -- True if payment date has passed
);
GO

-- ------------------------------------------------------------
-- CustomProfile: Override payment amounts per agreement
-- Takes priority over PaymentProfile when present
-- Optional: not all agreements have one
-- ------------------------------------------------------------
CREATE TABLE CustomProfile (
    CPAgreement               VARCHAR(20)    PRIMARY KEY REFERENCES Agreement(AgreementNumber),
    CPAmount                  DECIMAL(18,2)  NOT NULL,        -- Custom payment amount (total incl fees)
    CPFrequencyType           INT            NOT NULL DEFAULT 3, -- 3 = monthly
    CPDayOfMonth              INT            NULL,            -- Day of month for collection
    CPStartDate               DATE           NULL,
    CPOnGoing                 BIT            NOT NULL DEFAULT 1, -- True = active
    CPDeleted                 BIT            NOT NULL DEFAULT 0, -- Soft delete flag
    CPRepaymentMethod         INT            NULL              -- DO NOT rely on this - always check Agreement.AgreementPaymentMethod
);
GO

PRINT 'SentinelMock database and tables created successfully.';
GO
