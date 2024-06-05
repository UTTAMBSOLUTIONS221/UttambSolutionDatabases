CREATE TABLE [dbo].[Systemloanitempayments] (
    [AccountTopupId]       BIGINT          IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionId] BIGINT          NOT NULL,
    [AccountId]            BIGINT          NOT NULL,
    [Loandetailitemid]     BIGINT          NOT NULL,
    [Paymentamount]        DECIMAL (18, 2) NOT NULL,
    [Recievedamount]       DECIMAL (18, 2) NOT NULL,
    [ModeofPayment]        VARCHAR (400)   NOT NULL,
    [Paymentmemo]          VARCHAR (400)   NOT NULL,
    [Topupreference]       VARCHAR (400)   NOT NULL,
    [Topupreferencecode]   VARCHAR (100)   NULL,
    [Createdby]            BIGINT          NOT NULL,
    [Datecreated]          DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([AccountTopupId] ASC),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId]),
    FOREIGN KEY ([Loandetailitemid]) REFERENCES [dbo].[Systemloandetailitems] ([Loandetailitemid])
);

