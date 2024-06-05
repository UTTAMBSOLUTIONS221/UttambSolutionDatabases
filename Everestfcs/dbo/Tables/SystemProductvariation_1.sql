CREATE TABLE [dbo].[SystemProductvariation] (
    [ProductvariationId]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [Productvariationname]  VARCHAR (100)   NOT NULL,
    [ProductId]             BIGINT          NOT NULL,
    [TaxId]                 BIGINT          DEFAULT ((0)) NOT NULL,
    [Barcode]               VARCHAR (30)    NULL,
    [TaxclassificationCode] VARCHAR (100)   NULL,
    [Levyamount]            DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [Levyreference]         VARCHAR (100)   NULL,
    [Referencenumber]       VARCHAR (100)   NULL,
    [Imageurl]              VARCHAR (100)   NULL,
    [Isactive]              BIT             DEFAULT ((1)) NOT NULL,
    [Isdeleted]             BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]             BIGINT          NULL,
    [Modifiedby]            BIGINT          NULL,
    [DateCreated]           DATETIME        NOT NULL,
    [DateModified]          DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductvariationId] ASC)
);

