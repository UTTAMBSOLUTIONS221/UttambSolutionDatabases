CREATE TABLE [dbo].[SystemProduct] (
    [ProductId]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [TenantId]           BIGINT        NOT NULL,
    [CategoryId]         BIGINT        NOT NULL,
    [UomId]              BIGINT        NULL,
    [Productname]        VARCHAR (100) NOT NULL,
    [Productdescription] VARCHAR (100) NULL,
    [Createdby]          BIGINT        NULL,
    [Modifiedby]         BIGINT        NULL,
    [DateCreated]        DATETIME      NOT NULL,
    [DateModified]       DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductId] ASC)
);

