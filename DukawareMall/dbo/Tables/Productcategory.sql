CREATE TABLE [dbo].[Productcategory] (
    [CategoryId]      BIGINT       IDENTITY (1, 1) NOT NULL,
    [Categoryname]    VARCHAR (70) NOT NULL,
    [CategoryGroupId] BIGINT       NOT NULL,
    [ParentId]        BIGINT       DEFAULT ((0)) NOT NULL,
    [Isactive]        BIT          DEFAULT ((1)) NOT NULL,
    [Isdeleted]       BIT          DEFAULT ((0)) NOT NULL,
    [Createdby]       BIGINT       NOT NULL,
    [Modifiedby]      BIGINT       NOT NULL,
    [Datemodified]    DATETIME     NOT NULL,
    [Datecreated]     DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([CategoryId] ASC),
    FOREIGN KEY ([CategoryGroupId]) REFERENCES [dbo].[Productcategorygroup] ([CategoryGroupId])
);



