CREATE TABLE [dbo].[LpoTransactions] (
    [LpoTransactionId]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionId]      BIGINT          NOT NULL,
    [PostpaidOneOffAgreementId] BIGINT          NOT NULL,
    [Amount]                    DECIMAL (32, 2) NOT NULL,
    [IsActive]                  BIT             NOT NULL,
    [IsDeleted]                 BIT             NOT NULL,
    [CreatedBy]                 BIGINT          NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    CONSTRAINT [PK__LpoTr__3214EC07DCEF6BBA] PRIMARY KEY CLUSTERED ([LpoTransactionId] ASC),
    CONSTRAINT [FK_LPO_Transactions] FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId]),
    CONSTRAINT [FK_LPO_Transactions_Agreement] FOREIGN KEY ([PostpaidOneOffAgreementId]) REFERENCES [dbo].[PostpaidOneOffAgreements] ([PostpaidOneOffAgreementId])
);

