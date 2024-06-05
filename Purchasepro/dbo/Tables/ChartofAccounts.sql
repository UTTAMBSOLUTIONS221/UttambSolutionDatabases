CREATE TABLE [dbo].[ChartofAccounts] (
    [ChartofAccountId]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [ChartofAccountname] VARCHAR (80) NOT NULL,
    PRIMARY KEY CLUSTERED ([ChartofAccountId] ASC)
);

