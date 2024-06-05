CREATE TABLE [dbo].[LRConversionDataInputs] (
    [LRConversionDataInputId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [FinanceTransactionId]    BIGINT          NOT NULL,
    [FromReward]              BIGINT          NOT NULL,
    [ToReward]                BIGINT          NOT NULL,
    [StationId]               BIGINT          NOT NULL,
    [AccountNumber]           BIGINT          NOT NULL,
    [StaffId]                 BIGINT          NOT NULL,
    [IsProcessed]             BIT             NOT NULL,
    [DateCreated]             DATETIME        NOT NULL,
    [ConvertToAmount]         DECIMAL (18, 5) NOT NULL,
    [TransactionCode]         VARCHAR (100)   NULL,
    [Comments]                VARCHAR (200)   NULL,
    [RejectReason]            VARCHAR (100)   NULL,
    [Reject]                  BIT             CONSTRAINT [DF__LRConvers__Rejec__40863BEE] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__LRConver__3213E83F354DBDE7] PRIMARY KEY CLUSTERED ([LRConversionDataInputId] ASC)
);



