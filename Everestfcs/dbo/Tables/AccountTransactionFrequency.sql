CREATE TABLE [dbo].[AccountTransactionFrequency] (
    [AccountFrequencyId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT       NOT NULL,
    [Frequency]          INT          NOT NULL,
    [FrequencyPeriod]    VARCHAR (40) NOT NULL,
    [IsActive]           BIT          DEFAULT ((1)) NOT NULL,
    [IsDeleted]          BIT          DEFAULT ((0)) NOT NULL,
    [CreatedBy]          BIGINT       NULL,
    [ModifiedBy]         BIGINT       NULL,
    [DateCreated]        DATETIME     NULL,
    [DateModified]       DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([AccountFrequencyId] ASC),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId])
);

