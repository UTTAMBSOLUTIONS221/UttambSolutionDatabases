CREATE TABLE [dbo].[LTransactionTypes] (
    [LTransactionTypeId]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [LTransactionTypeName] VARCHAR (20) NOT NULL,
    PRIMARY KEY CLUSTERED ([LTransactionTypeId] ASC)
);

