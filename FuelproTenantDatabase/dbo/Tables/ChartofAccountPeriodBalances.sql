CREATE TABLE [dbo].[ChartofAccountPeriodBalances] (
    [PeriodBalanceId]  BIGINT          IDENTITY (1, 1) NOT NULL,
    [ChartofAccountId] BIGINT          NOT NULL,
    [PeriodId]         BIGINT          NOT NULL,
    [Bbfwd]            DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY CLUSTERED ([PeriodBalanceId] ASC),
    FOREIGN KEY ([ChartofAccountId]) REFERENCES [dbo].[ChartofAccounts] ([ChartofAccountId]),
    FOREIGN KEY ([PeriodId]) REFERENCES [dbo].[SystemPeriods] ([PeriodId])
);

