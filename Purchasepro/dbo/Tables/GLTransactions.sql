CREATE TABLE [dbo].[GLTransactions] (
    [GLTransactionId]      BIGINT          IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionId] BIGINT          NOT NULL,
    [ChartofAccountId]     BIGINT          NOT NULL,
    [Amount]               DECIMAL (18, 2) NOT NULL,
    [GlActualDate]         DATETIME        NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([GLTransactionId] ASC),
    FOREIGN KEY ([ChartofAccountId]) REFERENCES [dbo].[ChartofAccounts] ([ChartofAccountId]),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId])
);

