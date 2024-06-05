CREATE TABLE [dbo].[Tenantproduct] (
    [TenantproductId]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProductownerId]         BIGINT          NOT NULL,
    [SystemproductId]        BIGINT          NOT NULL,
    [Productunits]           DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [Productbuyingprice]     DECIMAL (30, 2) DEFAULT ((0)) NOT NULL,
    [Productoldsellingprice] DECIMAL (30, 2) NOT NULL,
    [Productsellingprice]    DECIMAL (30, 2) DEFAULT ((0)) NOT NULL,
    [Productdiscount]        DECIMAL (30, 2) DEFAULT ((0)) NOT NULL,
    [Extra]                  VARCHAR (100)   NULL,
    [Extra1]                 VARCHAR (100)   NULL,
    [Extra2]                 VARCHAR (100)   NULL,
    [Extra3]                 VARCHAR (100)   NULL,
    [Extra4]                 VARCHAR (100)   NULL,
    [Extra5]                 VARCHAR (100)   NULL,
    [Extra6]                 VARCHAR (100)   NULL,
    [Extra7]                 VARCHAR (100)   NULL,
    [Extra8]                 VARCHAR (100)   NULL,
    [Extra9]                 VARCHAR (100)   NULL,
    [Extra10]                VARCHAR (100)   NULL,
    [Isactive]               BIT             DEFAULT ((1)) NOT NULL,
    [Ishirepurchase]         BIT             DEFAULT ((0)) NOT NULL,
    [Isdeleted]              BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]              BIGINT          NOT NULL,
    [Modifiedby]             BIGINT          NOT NULL,
    [Datemodified]           DATETIME        NOT NULL,
    [Datecreated]            DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([TenantproductId] ASC),
    FOREIGN KEY ([SystemproductId]) REFERENCES [dbo].[Systemproduct] ([SystemproductId])
);





