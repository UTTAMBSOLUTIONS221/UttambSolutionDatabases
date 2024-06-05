CREATE TABLE [dbo].[CloseDays] (
    [CloseDayId] BIGINT   IDENTITY (1, 1) NOT NULL,
    [StartDate]  DATETIME NOT NULL,
    [EndDate]    DATETIME NULL,
    PRIMARY KEY CLUSTERED ([CloseDayId] ASC)
);





