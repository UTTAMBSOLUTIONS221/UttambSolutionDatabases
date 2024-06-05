CREATE TABLE [dbo].[LRConversionDataInputs] (
    [LRConversionDataInputId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [FromReward]              BIGINT          NOT NULL,
    [ToReward]                BIGINT          NOT NULL,
    [StationId]               BIGINT          NOT NULL,
    [AccountId]               BIGINT          NOT NULL,
    [StaffId]                 BIGINT          NOT NULL,
    [IsProcessed]             BIT             NOT NULL,
    [DateCreated]             DATETIME        NOT NULL,
    [ConvertToAmount]         DECIMAL (18, 5) NOT NULL,
    [FinanceTransactionId]    BIGINT          NOT NULL,
    [Comments]                VARCHAR (200)   NULL,
    CONSTRAINT [PK__LRConver__3213E83F354DBDE7] PRIMARY KEY CLUSTERED ([LRConversionDataInputId] ASC)
);



