CREATE TABLE [dbo].[PumpNozzles] (
    [Nozzleid] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Tankid]   BIGINT        NOT NULL,
    [Pumpid]   BIGINT        NOT NULL,
    [Side]     VARCHAR (20)  NULL,
    [Nozzle]   VARCHAR (100) NULL,
    CONSTRAINT [PK_dbo.PumpNozzles] PRIMARY KEY CLUSTERED ([Nozzleid] ASC),
    FOREIGN KEY ([Pumpid]) REFERENCES [dbo].[Stationpumps] ([Pumpid]),
    FOREIGN KEY ([Tankid]) REFERENCES [dbo].[Stationtanks] ([Tankid])
);



