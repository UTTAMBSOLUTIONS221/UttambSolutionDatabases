CREATE TABLE [dbo].[LRADataInputs] (
    [LRADataInputId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionId] BIGINT        NOT NULL,
    [GroupingId]           BIGINT        NOT NULL,
    [AccountId]            BIGINT        NOT NULL,
    [StationId]            BIGINT        NOT NULL,
    [TransactionDate]      DATE          NOT NULL,
    [TransactionTime]      TIME (7)      NOT NULL,
    [TransactionDay]       VARCHAR (20)  NOT NULL,
    [IsProcessed]          BIT           DEFAULT ((0)) NOT NULL,
    [IsRejected]           BIT           DEFAULT ((0)) NOT NULL,
    [RejectReason]         VARCHAR (400) NULL,
    [IsActive]             BIT           DEFAULT ((1)) NOT NULL,
    [IsDeleted]            BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]            BIGINT        NULL,
    [Modifiedby]           BIGINT        NULL,
    [DateCreated]          DATETIME      NULL,
    [DateModified]         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([LRADataInputId] ASC),
    FOREIGN KEY ([FinanceTransactionId]) REFERENCES [dbo].[FinanceTransactions] ([FinanceTransactionId]),
    FOREIGN KEY ([StationId]) REFERENCES [dbo].[SystemStations] ([Tenantstationid])
);



