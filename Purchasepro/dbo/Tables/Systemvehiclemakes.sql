CREATE TABLE [dbo].[Systemvehiclemakes] (
    [Vehiclemakeid]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [Vehiclemakename] VARCHAR (70) NOT NULL,
    PRIMARY KEY CLUSTERED ([Vehiclemakeid] ASC)
);

