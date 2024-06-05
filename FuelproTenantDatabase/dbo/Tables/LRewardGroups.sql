CREATE TABLE [dbo].[LRewardGroups] (
    [LRewardGroupId]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [RewardGroupName]        VARCHAR (70)  NOT NULL,
    [RewardGroupDescription] VARCHAR (200) NOT NULL,
    PRIMARY KEY CLUSTERED ([LRewardGroupId] ASC)
);

