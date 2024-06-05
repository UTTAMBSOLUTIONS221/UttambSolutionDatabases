CREATE TABLE [dbo].[DryStockMainStore] (
    [DryStockStoreId]    BIGINT       IDENTITY (1, 1) NOT NULL,
    [PurchaseId]         BIGINT       NOT NULL,
    [ProductVariationId] BIGINT       NOT NULL,
    [Quantity]           DECIMAL (18) DEFAULT ((0)) NOT NULL,
    [Createdby]          BIGINT       DEFAULT ((0)) NOT NULL,
    [Modifiedby]         BIGINT       DEFAULT ((0)) NOT NULL,
    [DateCreated]        DATETIME     DEFAULT (getdate()) NOT NULL,
    [DateModified]       DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([DryStockStoreId] ASC)
);



