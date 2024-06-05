CREATE TABLE [dbo].[DiscountSalesData] (
    [DiscountSaleId]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AutomationSaleId] BIGINT          NOT NULL,
    [DiscountType]     BIGINT          NULL,
    [PriceOrigin]      DECIMAL (18, 2) NULL,
    [PriceNew]         DECIMAL (18, 2) NULL,
    [PriceDiscount]    DECIMAL (18, 2) NULL,
    [VolOrigin]        DECIMAL (18, 2) NULL,
    [AmoOrigin]        DECIMAL (18, 2) NULL,
    [AmoNew]           DECIMAL (18, 2) NULL,
    [AmoDiscount]      DECIMAL (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([DiscountSaleId] ASC)
);

