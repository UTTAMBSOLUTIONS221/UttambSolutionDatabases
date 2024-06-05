CREATE TABLE [dbo].[AccountWeekDays] (
    [AccountWeekDaysId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT        NOT NULL,
    [WeekDays]          VARCHAR (200) NOT NULL,
    [StartTime]         VARCHAR (10)  NOT NULL,
    [EndTime]           VARCHAR (10)  NOT NULL,
    [IsActive]          BIT           DEFAULT ((1)) NOT NULL,
    [IsDeleted]         BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]         BIGINT        NULL,
    [ModifiedBy]        BIGINT        NULL,
    [DateCreated]       DATETIME      NULL,
    [DateModified]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([AccountWeekDaysId] ASC),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId])
);

