CREATE TABLE [dbo].[Productbrand] (
    [BrandId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [Brandname]     VARCHAR (70)  NOT NULL,
    [Brandimageurl] VARCHAR (200) NOT NULL,
    [Extra]         VARCHAR (100) NULL,
    [Extra1]        VARCHAR (100) NULL,
    [Extra2]        VARCHAR (100) NULL,
    [Extra3]        VARCHAR (100) NULL,
    [Extra4]        VARCHAR (100) NULL,
    [Extra5]        VARCHAR (100) NULL,
    [Extra6]        VARCHAR (100) NULL,
    [Extra7]        VARCHAR (100) NULL,
    [Extra8]        VARCHAR (100) NULL,
    [Extra9]        VARCHAR (100) NULL,
    [Extra10]       VARCHAR (100) NULL,
    [Isactive]      BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]     BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]     BIGINT        NOT NULL,
    [Modifiedby]    BIGINT        NOT NULL,
    [Datemodified]  DATETIME      NOT NULL,
    [Datecreated]   DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([BrandId] ASC)
);



