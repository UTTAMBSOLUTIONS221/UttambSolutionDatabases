CREATE TABLE [dbo].[EquipmentModels] (
    [EquipmentModelId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [EquipmentMakeId]  BIGINT       NOT NULL,
    [EquipmentModel]   VARCHAR (40) NOT NULL,
    PRIMARY KEY CLUSTERED ([EquipmentModelId] ASC),
    FOREIGN KEY ([EquipmentMakeId]) REFERENCES [dbo].[EquipmentMakes] ([EquipmentMakeId]),
    FOREIGN KEY ([EquipmentMakeId]) REFERENCES [dbo].[EquipmentMakes] ([EquipmentMakeId])
);



