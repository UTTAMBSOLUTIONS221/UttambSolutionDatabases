﻿CREATE TABLE [dbo].[ShiftVouchers] (
    [ShiftVoucherId]     BIGINT          IDENTITY (1, 1) NOT NULL,
    [ShiftId]            BIGINT          NOT NULL,
    [AttendantId]        BIGINT          NOT NULL,
    [VoucherType]        VARCHAR (50)    NOT NULL,
    [CreditDebit]        VARCHAR (50)    NOT NULL,
    [VoucherModeId]      BIGINT          NOT NULL,
    [VoucherName]        VARCHAR (100)   NULL,
    [ProductVariationId] BIGINT          DEFAULT ((0)) NOT NULL,
    [ProductQuantity]    DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ProductPrice]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ProductDiscount]    DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [VoucherAmount]      DECIMAL (18, 2) NOT NULL,
    [VatAmount]          DECIMAL (18, 2) NOT NULL,
    [RecieptNumber]      VARCHAR (100)   NULL,
    [CardNumber]         VARCHAR (100)   NULL,
    [Extra]              VARCHAR (100)   NULL,
    [Extra1]             VARCHAR (100)   NULL,
    [Extra2]             VARCHAR (100)   NULL,
    [Extra3]             VARCHAR (100)   NULL,
    [Extra4]             VARCHAR (100)   NULL,
    [Extra5]             VARCHAR (100)   NULL,
    [Extra6]             VARCHAR (100)   NULL,
    [Extra7]             VARCHAR (100)   NULL,
    [Extra8]             VARCHAR (100)   NULL,
    [Extra9]             VARCHAR (100)   NULL,
    [Extra10]            VARCHAR (100)   NULL,
    [Createdby]          BIGINT          NOT NULL,
    [Modifiedby]         BIGINT          NOT NULL,
    [Datemodified]       DATETIME        NOT NULL,
    [Datecreated]        DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([ShiftVoucherId] ASC)
);



