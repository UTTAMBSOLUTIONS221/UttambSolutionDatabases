CREATE TABLE [dbo].[LoyaltyGroupings] (
    [GroupingId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [Groupingname] VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([GroupingId] ASC),
    UNIQUE NONCLUSTERED ([Groupingname] ASC)
);

