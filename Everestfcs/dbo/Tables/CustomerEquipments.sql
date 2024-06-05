CREATE TABLE [dbo].[CustomerEquipments] (
    [EquipmentId]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProductVariationId] BIGINT          NOT NULL,
    [EquipmentMakeId]    BIGINT          DEFAULT ((0)) NOT NULL,
    [EquipmentModelId]   BIGINT          NOT NULL,
    [EquipmentRegNo]     VARCHAR (200)   NOT NULL,
    [TankCapacity]       DECIMAL (20, 2) NOT NULL,
    [Odometer]           DECIMAL (20, 2) DEFAULT ((0)) NOT NULL,
    [IsActive]           BIT             DEFAULT ((1)) NOT NULL,
    [IsDeleted]          BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]          BIGINT          NULL,
    [Modifiedby]         BIGINT          NULL,
    [DateCreated]        DATETIME        NULL,
    [DateModified]       DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([EquipmentId] ASC),
    FOREIGN KEY ([EquipmentModelId]) REFERENCES [dbo].[EquipmentModels] ([EquipmentModelId]),
    FOREIGN KEY ([EquipmentModelId]) REFERENCES [dbo].[EquipmentModels] ([EquipmentModelId]),
    FOREIGN KEY ([EquipmentModelId]) REFERENCES [dbo].[EquipmentModels] ([EquipmentModelId]),
    FOREIGN KEY ([ProductVariationId]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId]),
    FOREIGN KEY ([ProductVariationId]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId]),
    FOREIGN KEY ([ProductVariationId]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId])
);



