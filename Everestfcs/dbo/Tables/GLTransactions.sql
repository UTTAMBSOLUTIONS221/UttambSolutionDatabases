CREATE TABLE [dbo].[GLTransactions] (
    [GLTransactionId]      BIGINT          IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionId] BIGINT          NOT NULL,
    [ChartofAccountId]     BIGINT          NOT NULL,
    [PeriodId]             BIGINT          NOT NULL,
    [Currency]             VARCHAR (20)    NOT NULL,
    [Amount]               DECIMAL (18, 2) NOT NULL,
    [GlActualDate]         DATETIME        NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([GLTransactionId] ASC),
    FOREIGN KEY ([ChartofAccountId]) REFERENCES [dbo].[ChartofAccounts] ([ChartofAccountId]),
    FOREIGN KEY ([ChartofAccountId]) REFERENCES [dbo].[ChartofAccounts] ([ChartofAccountId]),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId]),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId]),
    FOREIGN KEY ([PeriodId]) REFERENCES [dbo].[SystemPeriods] ([PeriodId]),
    FOREIGN KEY ([PeriodId]) REFERENCES [dbo].[SystemPeriods] ([PeriodId])
);

