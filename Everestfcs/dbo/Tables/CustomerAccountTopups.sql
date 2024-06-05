CREATE TABLE [dbo].[CustomerAccountTopups] (
    [AccountTopupId]       BIGINT          IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionId] BIGINT          NOT NULL,
    [AccountId]            BIGINT          NOT NULL,
    [StationId]            BIGINT          NOT NULL,
    [StaffId]              BIGINT          DEFAULT ((0)) NOT NULL,
    [ModeofPayment]        VARCHAR (20)    NOT NULL,
    [Topupreference]       VARCHAR (100)   NULL,
    [Amount]               DECIMAL (18, 2) NOT NULL,
    [Erprefe]              VARCHAR (100)   NULL,
    [Chequeno]             VARCHAR (100)   NULL,
    [Bankaccno]            VARCHAR (100)   NULL,
    [Drawerbank]           VARCHAR (100)   NULL,
    [Payeebank]            VARCHAR (100)   NULL,
    [Branchdeposited]      VARCHAR (100)   NULL,
    [Depositslip]          VARCHAR (100)   NULL,
    [Createdby]            BIGINT          NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([AccountTopupId] ASC),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId]),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId])
);

