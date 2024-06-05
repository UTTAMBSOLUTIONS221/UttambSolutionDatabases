CREATE TABLE [dbo].[Productcategory] (
    [CategoryId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [Categoryname] VARCHAR (100) NOT NULL,
    [Createdby]    BIGINT        NOT NULL,
    [Modifiedby]   BIGINT        NOT NULL,
    [Datecreated]  DATETIME      NOT NULL,
    [Datemodified] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([CategoryId] ASC)
);

