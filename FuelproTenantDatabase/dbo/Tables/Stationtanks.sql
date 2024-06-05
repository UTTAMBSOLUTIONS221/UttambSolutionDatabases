CREATE TABLE [dbo].[Stationtanks] (
    [Tankid]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [Stationid]            BIGINT          NOT NULL,
    [Productvariationid]   BIGINT          NOT NULL,
    [Name]                 NVARCHAR (100)  NULL,
    [Description]          NVARCHAR (200)  NULL,
    [Length]               DECIMAL (10, 2) NOT NULL,
    [Diameter]             DECIMAL (10, 2) NOT NULL,
    [Volume]               DECIMAL (10, 2) NOT NULL,
    [NumberOfCalibrations] INT             NOT NULL,
    [IsActive]             BIT             NOT NULL,
    [IsDeleted]            BIT             NOT NULL,
    [CreatedBy]            BIGINT          NOT NULL,
    [ModifiedBy]           BIGINT          NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [DateModified]         DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.Stationtanks] PRIMARY KEY CLUSTERED ([Tankid] ASC),
    FOREIGN KEY ([Productvariationid]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId]),
    FOREIGN KEY ([Stationid]) REFERENCES [dbo].[SystemStations] ([Tenantstationid])
);

