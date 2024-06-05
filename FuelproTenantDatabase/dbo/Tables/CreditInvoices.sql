﻿CREATE TABLE [dbo].[CreditInvoices] (
    [InvoiceId]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]            VARCHAR (50)    NOT NULL,
    [CreditAgreementId]    BIGINT          NOT NULL,
    [FinanceTransactionId] BIGINT          NOT NULL,
    [TransactionDate]      DATETIME        NOT NULL,
    [PostingDate]          DATETIME        NOT NULL,
    [DueDate]              DATETIME        NOT NULL,
    [AccountId]            BIGINT          NOT NULL,
    [Amount]               DECIMAL (18, 2) NOT NULL,
    [Discount]             DECIMAL (18, 2) NOT NULL,
    [ProductVariationId]   BIGINT          NOT NULL,
    [Units]                DECIMAL (18, 2) NOT NULL,
    [Price]                DECIMAL (18, 2) NOT NULL,
    [IsPaid]               BIT             DEFAULT ((0)) NOT NULL,
    [PaidAmount]           DECIMAL (18, 2) NULL,
    [PayStatus]            VARCHAR (30)    NULL,
    [Balance]              DECIMAL (18, 2) NOT NULL,
    [IsReversed]           BIT             DEFAULT ((0)) NOT NULL,
    [IsActive]             BIT             NOT NULL,
    [IsDeleted]            BIT             NOT NULL,
    [IsOverConsumption]    BIT             DEFAULT ((0)) NOT NULL,
    [CreatedBy]            BIGINT          NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([InvoiceId] ASC),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId])
);



