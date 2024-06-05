CREATE TABLE [dbo].[ShiftPurchases] (
    [PurchaseId]      BIGINT          IDENTITY (1, 1) NOT NULL,
    [ShiftId]         BIGINT          NOT NULL,
    [WetDryPurchase]  VARCHAR (50)    NOT NULL,
    [InvoiceNumber]   VARCHAR (50)    NOT NULL,
    [SupplierId]      BIGINT          NOT NULL,
    [InvoiceAmount]   DECIMAL (18, 2) NOT NULL,
    [TransportAmount] DECIMAL (18, 2) NOT NULL,
    [InvoiceDate]     DATETIME        NOT NULL,
    [TruckNumber]     VARCHAR (100)   NOT NULL,
    [DriverName]      VARCHAR (100)   NOT NULL,
    [Extra]           VARCHAR (100)   NULL,
    [Extra1]          VARCHAR (100)   NULL,
    [Extra2]          VARCHAR (100)   NULL,
    [Extra3]          VARCHAR (100)   NULL,
    [Extra4]          VARCHAR (100)   NULL,
    [Extra5]          VARCHAR (100)   NULL,
    [Extra6]          VARCHAR (100)   NULL,
    [Extra7]          VARCHAR (100)   NULL,
    [Extra8]          VARCHAR (100)   NULL,
    [Extra9]          VARCHAR (100)   NULL,
    [Extra10]         VARCHAR (100)   NULL,
    [Createdby]       BIGINT          NOT NULL,
    [Modifiedby]      BIGINT          NOT NULL,
    [Datemodified]    DATETIME        NOT NULL,
    [Datecreated]     DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([PurchaseId] ASC)
);



