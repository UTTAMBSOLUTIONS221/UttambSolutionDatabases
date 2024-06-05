CREATE TABLE [dbo].[EquipmentTransactionFrequency] (
    [EquipmentFrequencyId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [EquipmentId]          BIGINT       NOT NULL,
    [Frequency]            INT          NOT NULL,
    [FrequencyPeriod]      VARCHAR (40) NOT NULL,
    [IsActive]             BIT          DEFAULT ((1)) NOT NULL,
    [IsDeleted]            BIT          DEFAULT ((0)) NOT NULL,
    [CreatedBy]            BIGINT       NULL,
    [ModifiedBy]           BIGINT       NULL,
    [DateCreated]          DATETIME     NULL,
    [DateModified]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([EquipmentFrequencyId] ASC),
    FOREIGN KEY ([EquipmentId]) REFERENCES [dbo].[CustomerEquipments] ([EquipmentId]),
    FOREIGN KEY ([EquipmentId]) REFERENCES [dbo].[CustomerEquipments] ([EquipmentId])
);



