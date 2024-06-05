CREATE TABLE [dbo].[RFIDCardSalesData] (
    [RFIDCardSaleId]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AutomationSaleId] BIGINT          NOT NULL,
    [Used]             BIGINT          NULL,
    [CardType]         BIGINT          NULL,
    [Num]              VARCHAR (50)    NULL,
    [Num10]            VARCHAR (50)    NULL,
    [CustName]         VARCHAR (50)    NULL,
    [CustIdType]       BIGINT          NULL,
    [CustId]           BIGINT          NULL,
    [CustContact]      VARCHAR (50)    NULL,
    [PayMethod]        BIGINT          NULL,
    [DiscountType]     BIGINT          NULL,
    [Discount]         DECIMAL (18, 2) NULL,
    [ProductEnabled]   VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([RFIDCardSaleId] ASC)
);

