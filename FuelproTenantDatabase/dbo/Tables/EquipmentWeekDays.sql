CREATE TABLE [dbo].[EquipmentWeekDays] (
    [EquipmentWeekDaysId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [EquipmentId]         BIGINT        NOT NULL,
    [WeekDays]            VARCHAR (200) NOT NULL,
    [StartTime]           VARCHAR (10)  NOT NULL,
    [EndTime]             VARCHAR (10)  NOT NULL,
    [IsActive]            BIT           DEFAULT ((1)) NOT NULL,
    [IsDeleted]           BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]           BIGINT        NULL,
    [ModifiedBy]          BIGINT        NULL,
    [DateCreated]         DATETIME      NULL,
    [DateModified]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([EquipmentWeekDaysId] ASC),
    FOREIGN KEY ([EquipmentId]) REFERENCES [dbo].[CustomerEquipments] ([EquipmentId]),
    FOREIGN KEY ([EquipmentId]) REFERENCES [dbo].[CustomerEquipments] ([EquipmentId])
);



