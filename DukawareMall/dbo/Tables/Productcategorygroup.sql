CREATE TABLE [dbo].[Productcategorygroup] (
    [CategoryGroupId]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [CategoryGroupName]   VARCHAR (100) NOT NULL,
    [Categorygroupimgurl] VARCHAR (200) NOT NULL,
    PRIMARY KEY CLUSTERED ([CategoryGroupId] ASC),
    UNIQUE NONCLUSTERED ([CategoryGroupName] ASC)
);

