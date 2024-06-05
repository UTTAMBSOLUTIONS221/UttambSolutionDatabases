CREATE TABLE [dbo].[SystemCountryRegionsAreas] (
    [RegionAreaId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [RegionId]       BIGINT        NOT NULL,
    [RegionAreaName] VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([RegionAreaId] ASC)
);

