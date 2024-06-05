CREATE TABLE [dbo].[ChartofAccountsSubTypes] (
    [ChartofAccountSubTypeId]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [ChartofAccountSubTypename] VARCHAR (40) NOT NULL,
    [ChartofAccountTypeId]      BIGINT       NULL,
    PRIMARY KEY CLUSTERED ([ChartofAccountSubTypeId] ASC),
    FOREIGN KEY ([ChartofAccountTypeId]) REFERENCES [dbo].[ChartofAccountTypes] ([ChartofAccountTypeId]),
    FOREIGN KEY ([ChartofAccountTypeId]) REFERENCES [dbo].[ChartofAccountTypes] ([ChartofAccountTypeId])
);



