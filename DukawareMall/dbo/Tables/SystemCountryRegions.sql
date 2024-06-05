CREATE TABLE [dbo].[SystemCountryRegions] (
    [RegionId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [CountryId]  BIGINT        NOT NULL,
    [RegionName] VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([RegionId] ASC)
);

