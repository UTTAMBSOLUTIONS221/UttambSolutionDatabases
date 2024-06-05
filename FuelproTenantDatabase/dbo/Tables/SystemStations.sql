CREATE TABLE [dbo].[SystemStations] (
    [StationId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [Sname]           VARCHAR (100) NOT NULL,
    [Tenantstationid] BIGINT        NOT NULL,
    PRIMARY KEY CLUSTERED ([StationId] ASC),
    UNIQUE NONCLUSTERED ([Sname] ASC),
    UNIQUE NONCLUSTERED ([Tenantstationid] ASC)
);



