CREATE TABLE [dbo].[AccountStations] (
    [AccountStationId] BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT   NOT NULL,
    [StationId]        BIGINT   NOT NULL,
    [IsActive]         BIT      DEFAULT ((1)) NOT NULL,
    [IsDeleted]        BIT      DEFAULT ((0)) NOT NULL,
    [CreatedBy]        BIGINT   NULL,
    [ModifiedBy]       BIGINT   NULL,
    [DateCreated]      DATETIME NULL,
    [DateModified]     DATETIME NULL,
    PRIMARY KEY CLUSTERED ([AccountStationId] ASC),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId])
);

