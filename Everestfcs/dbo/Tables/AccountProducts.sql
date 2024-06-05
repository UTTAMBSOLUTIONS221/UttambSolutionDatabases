CREATE TABLE [dbo].[AccountProducts] (
    [AccountProductId]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT          NOT NULL,
    [ProductVariationId] BIGINT          NOT NULL,
    [LimitValue]         DECIMAL (10, 2) NOT NULL,
    [LimitPeriod]        VARCHAR (40)    NOT NULL,
    [IsActive]           BIT             DEFAULT ((1)) NOT NULL,
    [IsDeleted]          BIT             DEFAULT ((0)) NOT NULL,
    [CreatedBy]          BIGINT          NULL,
    [ModifiedBy]         BIGINT          NULL,
    [DateCreated]        DATETIME        NULL,
    [DateModified]       DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([AccountProductId] ASC),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([ProductVariationId]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId]),
    FOREIGN KEY ([ProductVariationId]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId])
);



