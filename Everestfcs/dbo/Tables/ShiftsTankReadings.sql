CREATE TABLE [dbo].[ShiftsTankReadings] (
    [ShiftTankReadingId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [ShiftId]            BIGINT          NOT NULL,
    [TankId]             BIGINT          NOT NULL,
    [AttendantId]        BIGINT          NOT NULL,
    [ProductPrice]       DECIMAL (18, 2) NOT NULL,
    [OpeningQuantity]    DECIMAL (18, 2) NOT NULL,
    [ClosingQuantity]    DECIMAL (18, 2) NOT NULL,
    [QuantitySold]       DECIMAL (18, 2) NOT NULL,
    [AmountSold]         DECIMAL (18, 2) NOT NULL,
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
    PRIMARY KEY CLUSTERED ([ShiftTankReadingId] ASC)
);



