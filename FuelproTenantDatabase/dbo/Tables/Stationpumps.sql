CREATE TABLE [dbo].[Stationpumps] (
    [Pumpid]        BIGINT         IDENTITY (1, 1) NOT NULL,
    [Stationid]     BIGINT         NOT NULL,
    [Tankid]        BIGINT         NOT NULL,
    [Pumpname]      NVARCHAR (100) NULL,
    [Pumpmodel]     NVARCHAR (100) NULL,
    [Description]   NVARCHAR (200) NULL,
    [Code]          NVARCHAR (50)  NULL,
    [IsDoubleSided] BIT            NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedBy]     BIGINT         NOT NULL,
    [ModifiedBy]    BIGINT         NOT NULL,
    [DateCreated]   DATETIME       NOT NULL,
    [DateModified]  DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.Stationpumps] PRIMARY KEY CLUSTERED ([Pumpid] ASC),
    FOREIGN KEY ([Stationid]) REFERENCES [dbo].[SystemStations] ([Tenantstationid])
);



