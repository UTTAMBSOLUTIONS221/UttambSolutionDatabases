CREATE TABLE [dbo].[SystemPeriods] (
    [PeriodId]         BIGINT   IDENTITY (1, 1) NOT NULL,
    [Lastdateinperiod] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([PeriodId] ASC)
);

