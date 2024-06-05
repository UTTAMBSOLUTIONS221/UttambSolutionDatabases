CREATE TABLE [dbo].[EquipmentMakes] (
    [EquipmentMakeId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [EquipmentMake]   VARCHAR (40) NOT NULL,
    PRIMARY KEY CLUSTERED ([EquipmentMakeId] ASC)
);

