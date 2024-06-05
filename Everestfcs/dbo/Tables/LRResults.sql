CREATE TABLE [dbo].[LRResults] (
    [LRResultId]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]               BIGINT          NOT NULL,
    [LRewardId]               BIGINT          NOT NULL,
    [LTransactionTypeId]      BIGINT          NOT NULL,
    [LRADataInputId]          BIGINT          DEFAULT ((0)) NOT NULL,
    [LRConversionDataInputId] BIGINT          DEFAULT ((0)) NOT NULL,
    [RewardAmount]            DECIMAL (10, 2) NOT NULL,
    [IsActive]                BIT             DEFAULT ((1)) NOT NULL,
    [IsDeleted]               BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]               BIGINT          NULL,
    [Modifiedby]              BIGINT          NULL,
    [ActualDateCreated]       DATETIME        NULL,
    [DateCreated]             DATETIME        NULL,
    [DateModified]            DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([LRResultId] ASC),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([LRewardId]) REFERENCES [dbo].[LRewards] ([LRewardId]),
    FOREIGN KEY ([LTransactionTypeId]) REFERENCES [dbo].[LTransactionTypes] ([LTransactionTypeId])
);

