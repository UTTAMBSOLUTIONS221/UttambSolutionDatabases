CREATE TABLE [dbo].[FinanceTransactionSubTypes] (
    [FinanceTransactionSubTypeId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionSubType]   VARCHAR (100) NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([FinanceTransactionSubTypeId] ASC)
);

