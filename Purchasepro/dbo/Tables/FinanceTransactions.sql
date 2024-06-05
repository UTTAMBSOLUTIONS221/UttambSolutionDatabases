CREATE TABLE [dbo].[FinanceTransactions] (
    [FinanceTransactionId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [TransactionCode]      VARCHAR (100) NOT NULL,
    [ParentId]             BIGINT        DEFAULT ((0)) NOT NULL,
    [Saledescription]      VARCHAR (100) NULL,
    [SaleRefence]          VARCHAR (100) NULL,
    [Createdby]            BIGINT        NOT NULL,
    [ActualDate]           DATETIME      NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([FinanceTransactionId] ASC)
);

