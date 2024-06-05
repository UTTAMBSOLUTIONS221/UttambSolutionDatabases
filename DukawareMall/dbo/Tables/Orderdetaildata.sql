CREATE TABLE [dbo].[Orderdetaildata] (
    [Orderdetailid] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Odernumber]    VARCHAR (100)   NOT NULL,
    [Orderownerid]  BIGINT          NOT NULL,
    [Orderamount]   DECIMAL (10, 2) NOT NULL,
    [Orderunits]    DECIMAL (10, 2) NOT NULL,
    [Orderstatus]   INT             NOT NULL,
    [Isactive]      BIT             DEFAULT ((1)) NOT NULL,
    [Isdeleted]     BIT             DEFAULT ((0)) NOT NULL,
    [Extra]         VARCHAR (100)   NULL,
    [Extra1]        VARCHAR (100)   NULL,
    [Extra2]        VARCHAR (100)   NULL,
    [Extra3]        VARCHAR (100)   NULL,
    [Extra4]        VARCHAR (100)   NULL,
    [Extra5]        VARCHAR (100)   NULL,
    [Extra6]        VARCHAR (100)   NULL,
    [Extra7]        VARCHAR (100)   NULL,
    [Extra8]        VARCHAR (100)   NULL,
    [Extra9]        VARCHAR (100)   NULL,
    [Orderdate]     DATETIME        NOT NULL,
    [Datecreated]   DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([Orderdetailid] ASC)
);

