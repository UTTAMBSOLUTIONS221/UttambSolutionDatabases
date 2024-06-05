CREATE TABLE [dbo].[SystemSuplierPrice] (
    [SupplierPriceId]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [SupplierId]         BIGINT          NOT NULL,
    [ProductVariationId] BIGINT          NOT NULL,
    [ProductPrice]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ProductVat]         DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [Createdby]          BIGINT          NOT NULL,
    [Modifiedby]         BIGINT          NOT NULL,
    [DateCreated]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [DateModified]       DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([SupplierPriceId] ASC)
);

