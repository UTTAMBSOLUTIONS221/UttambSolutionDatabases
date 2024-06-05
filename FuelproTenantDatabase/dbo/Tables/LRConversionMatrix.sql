CREATE TABLE [dbo].[LRConversionMatrix] (
    [ConversionMatrixid] BIGINT          IDENTITY (1, 1) NOT NULL,
    [FromReward]         BIGINT          NOT NULL,
    [ToReward]           BIGINT          NOT NULL,
    [ConversionRatio]    DECIMAL (18, 5) NOT NULL,
    CONSTRAINT [PK_LoyaltyRewardConversionMatrix] PRIMARY KEY CLUSTERED ([ConversionMatrixid] ASC)
);

