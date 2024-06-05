CREATE TABLE [dbo].[Systemproduct] (
    [SystemproductId]  BIGINT          IDENTITY (1, 1) NOT NULL,
    [CategoryGroupId]  BIGINT          NOT NULL,
    [CategoryId]       BIGINT          NOT NULL,
    [SubCategoryId]    BIGINT          NOT NULL,
    [UomId]            BIGINT          NOT NULL,
    [UomItemId]        BIGINT          NOT NULL,
    [BrandId]          BIGINT          NOT NULL,
    [Productname]      VARCHAR (100)   NOT NULL,
    [Productbarcode]   VARCHAR (100)   NOT NULL,
    [Wholesaleprice]   DECIMAL (12, 2) NOT NULL,
    [Marketsaleprice]  DECIMAL (12, 2) NOT NULL,
    [Productimageurl1] VARCHAR (100)   NOT NULL,
    [Productimageurl2] VARCHAR (100)   NULL,
    [Productimageurl3] VARCHAR (100)   NULL,
    [Productimageurl4] VARCHAR (100)   NULL,
    [Productimageurl5] VARCHAR (100)   NULL,
    [Extra]            VARCHAR (100)   NULL,
    [Extra1]           VARCHAR (100)   NULL,
    [Extra2]           VARCHAR (100)   NULL,
    [Extra3]           VARCHAR (100)   NULL,
    [Extra4]           VARCHAR (100)   NULL,
    [Extra5]           VARCHAR (100)   NULL,
    [Extra6]           VARCHAR (100)   NULL,
    [Extra7]           VARCHAR (100)   NULL,
    [Extra8]           VARCHAR (100)   NULL,
    [Extra9]           VARCHAR (100)   NULL,
    [Extra10]          VARCHAR (100)   NULL,
    [Isactive]         BIT             DEFAULT ((1)) NOT NULL,
    [Isdeleted]        BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]        BIGINT          NOT NULL,
    [Modifiedby]       BIGINT          NOT NULL,
    [Datemodified]     DATETIME        NOT NULL,
    [Datecreated]      DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([SystemproductId] ASC),
    FOREIGN KEY ([BrandId]) REFERENCES [dbo].[Productbrand] ([BrandId]),
    FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[Productcategory] ([CategoryId]),
    FOREIGN KEY ([UomId]) REFERENCES [dbo].[Productuom] ([UomId])
);









