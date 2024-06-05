CREATE TABLE [dbo].[LRewards] (
    [LRewardId]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [LRewardGroupId]         BIGINT          NOT NULL,
    [RewardName]             VARCHAR (70)    NOT NULL,
    [MinimumToRedeem]        DECIMAL (10, 2) NOT NULL,
    [IsEarnable]             BIT             DEFAULT ((0)) NOT NULL,
    [IsWholeorDecimal]       VARCHAR (30)    NOT NULL,
    [IsWholeCeilorFloor]     VARCHAR (30)    NOT NULL,
    [IsDecimalRoundofNumber] INT             NOT NULL,
    [IsVirtual]              BIT             DEFAULT ((0)) NOT NULL,
    [IsCash]                 BIT             DEFAULT ((0)) NOT NULL,
    [IsInternal]             BIT             DEFAULT ((0)) NOT NULL,
    [IsActive]               BIT             DEFAULT ((1)) NOT NULL,
    [IsDeleted]              BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]              BIGINT          NULL,
    [Modifiedby]             BIGINT          NULL,
    [DateCreated]            DATETIME        NULL,
    [DateModified]           DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([LRewardId] ASC),
    FOREIGN KEY ([LRewardGroupId]) REFERENCES [dbo].[LRewardGroups] ([LRewardGroupId]),
    FOREIGN KEY ([LRewardGroupId]) REFERENCES [dbo].[LRewardGroups] ([LRewardGroupId])
);



