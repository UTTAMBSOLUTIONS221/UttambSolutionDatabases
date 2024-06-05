CREATE TABLE [dbo].[DryStockMovement] (
    [DryStockMoveId]     BIGINT          IDENTITY (1, 1) NOT NULL,
    [DryStockStoreId]    BIGINT          NOT NULL,
    [ProductVariationId] BIGINT          NOT NULL,
    [ShiftId]            BIGINT          NOT NULL,
    [Quantity]           DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [Movement]           VARCHAR (100)   NOT NULL,
    [Createdby]          BIGINT          NOT NULL,
    [Modifiedby]         BIGINT          NOT NULL,
    [DateCreated]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [DateModified]       DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([DryStockMoveId] ASC)
);



