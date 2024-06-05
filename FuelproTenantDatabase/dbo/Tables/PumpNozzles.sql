CREATE TABLE [dbo].[PumpNozzles] (
    [Nozzleid]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [Tankid]    BIGINT         NOT NULL,
    [Pumpid]    BIGINT         NOT NULL,
    [Side]      NVARCHAR (20)  NULL,
    [Code]      NVARCHAR (50)  NOT NULL,
    [Nozzle]    NVARCHAR (100) NULL,
    [IsActive]  BIT            NULL,
    [IsDeleted] BIT            NULL,
    CONSTRAINT [PK_dbo.PumpNozzles] PRIMARY KEY CLUSTERED ([Nozzleid] ASC),
    FOREIGN KEY ([Pumpid]) REFERENCES [dbo].[Stationpumps] ([Pumpid]),
    FOREIGN KEY ([Tankid]) REFERENCES [dbo].[Stationtanks] ([Tankid])
);

