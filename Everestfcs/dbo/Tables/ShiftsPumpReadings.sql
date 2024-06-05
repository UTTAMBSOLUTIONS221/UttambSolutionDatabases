CREATE TABLE [dbo].[ShiftsPumpReadings] (
    [ShiftPumpReadingId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [ShiftId]            BIGINT          NOT NULL,
    [PumpId]             BIGINT          NOT NULL,
    [NozzleId]           BIGINT          NOT NULL,
    [AttendantId]        BIGINT          NOT NULL,
    [ProductPrice]       DECIMAL (18, 2) NOT NULL,
    [OpeningShilling]    DECIMAL (18, 2) NOT NULL,
    [ClosingShilling]    DECIMAL (18, 2) NOT NULL,
    [TotalShilling]      DECIMAL (18, 2) NOT NULL,
    [ShillingDifference] DECIMAL (18, 2) NOT NULL,
    [OpeningElectronic]  DECIMAL (18, 2) NOT NULL,
    [ClosingElectronic]  DECIMAL (18, 2) NOT NULL,
    [ElectronicSold]     DECIMAL (18, 2) NOT NULL,
    [ElectronicAmount]   DECIMAL (18, 2) NOT NULL,
    [OpeningManual]      DECIMAL (18, 2) NOT NULL,
    [ClosingManual]      DECIMAL (18, 2) NOT NULL,
    [ManualSold]         DECIMAL (18, 2) NOT NULL,
    [ManualAmount]       DECIMAL (18, 2) NOT NULL,
    [LitersDifference]   DECIMAL (18, 2) NOT NULL,
    [TestingRtt]         DECIMAL (18, 2) NOT NULL,
    [PumpRttAmount]      DECIMAL (18, 2) NOT NULL,
    [TotalPumpAmount]    DECIMAL (18, 2) NOT NULL,
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
    PRIMARY KEY CLUSTERED ([ShiftPumpReadingId] ASC)
);







