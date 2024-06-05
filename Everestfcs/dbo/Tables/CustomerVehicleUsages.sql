CREATE TABLE [dbo].[CustomerVehicleUsages] (
    [Vehicleusageid] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Odometer]       DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [EquipmentId]    BIGINT          NOT NULL,
    [TicketId]       BIGINT          NOT NULL,
    [DateCreated]    DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([Vehicleusageid] ASC)
);

