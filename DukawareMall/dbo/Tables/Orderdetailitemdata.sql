CREATE TABLE [dbo].[Orderdetailitemdata] (
    [Orderdetailitemid] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Orderdetailid]     BIGINT          NOT NULL,
    [Productid]         BIGINT          NOT NULL,
    [Shopid]            BIGINT          NOT NULL,
    [Productunit]       DECIMAL (10, 2) NOT NULL,
    [Unitprice]         DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY CLUSTERED ([Orderdetailitemid] ASC)
);

