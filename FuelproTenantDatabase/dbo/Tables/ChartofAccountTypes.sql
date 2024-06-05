CREATE TABLE [dbo].[ChartofAccountTypes] (
    [ChartofAccountTypeId]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [ChartofAccountTypename] VARCHAR (40) NOT NULL,
    [IsGLType]               BIT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ChartofAccountTypeId] ASC)
);

