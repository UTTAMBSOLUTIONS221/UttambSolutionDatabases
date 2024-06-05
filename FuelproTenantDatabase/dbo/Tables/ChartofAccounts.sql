CREATE TABLE [dbo].[ChartofAccounts] (
    [ChartofAccountId]        BIGINT       IDENTITY (1, 1) NOT NULL,
    [ChartofAccountname]      VARCHAR (80) NOT NULL,
    [ChartofAccountSubTypeId] BIGINT       NULL,
    PRIMARY KEY CLUSTERED ([ChartofAccountId] ASC),
    FOREIGN KEY ([ChartofAccountSubTypeId]) REFERENCES [dbo].[ChartofAccountsSubTypes] ([ChartofAccountSubTypeId]),
    FOREIGN KEY ([ChartofAccountSubTypeId]) REFERENCES [dbo].[ChartofAccountsSubTypes] ([ChartofAccountSubTypeId])
);



