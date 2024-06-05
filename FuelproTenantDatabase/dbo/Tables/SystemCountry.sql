CREATE TABLE [dbo].[SystemCountry] (
    [CountryId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [Countryname] VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([CountryId] ASC),
    UNIQUE NONCLUSTERED ([Countryname] ASC)
);



