CREATE TABLE [dbo].[Systemvehiclemodels] (
    [Vehiclemodelid]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [Vehiclemakeid]    BIGINT       NOT NULL,
    [Vehiclemodelname] VARCHAR (70) NOT NULL,
    PRIMARY KEY CLUSTERED ([Vehiclemodelid] ASC)
);

