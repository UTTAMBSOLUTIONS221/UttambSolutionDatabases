CREATE TABLE [dbo].[FinanceTransactionTypes] (
    [FinanceTransactionTypeId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionType]   VARCHAR (100) NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([FinanceTransactionTypeId] ASC)
);

