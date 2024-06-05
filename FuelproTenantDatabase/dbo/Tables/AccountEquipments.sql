CREATE TABLE [dbo].[AccountEquipments] (
    [AccountId]   BIGINT NOT NULL,
    [EquipmentId] BIGINT NOT NULL,
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([EquipmentId]) REFERENCES [dbo].[CustomerEquipments] ([EquipmentId]),
    FOREIGN KEY ([EquipmentId]) REFERENCES [dbo].[CustomerEquipments] ([EquipmentId]),
    FOREIGN KEY ([EquipmentId]) REFERENCES [dbo].[CustomerEquipments] ([EquipmentId])
);



