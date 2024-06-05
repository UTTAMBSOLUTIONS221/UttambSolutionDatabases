CREATE TABLE [dbo].[Stationshifts] (
    [ShiftId]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [StationId]          BIGINT          NOT NULL,
    [ShiftCode]          VARCHAR (50)    NOT NULL,
    [ShiftCategory]      VARCHAR (50)    NOT NULL,
    [CashOrAccount]      VARCHAR (50)    NOT NULL,
    [ShiftDateTime]      DATETIME        NOT NULL,
    [ShiftStatus]        INT             NOT NULL,
    [IsPosted]           BIT             CONSTRAINT [DF_Stationshifts_IsPosted] DEFAULT ((0)) NOT NULL,
    [IsDeleted]          BIT             CONSTRAINT [DF_Stationshifts_IsDeleted] DEFAULT ((0)) NOT NULL,
    [ShiftTotalAmount]   DECIMAL (18, 2) CONSTRAINT [DF_Stationshifts_ShiftTotalAmount] DEFAULT ((0)) NOT NULL,
    [ShiftBankedAmount]  DECIMAL (18, 2) CONSTRAINT [DF_Stationshifts_ShiftBankedAmount] DEFAULT ((0)) NOT NULL,
    [ShiftBalance]       DECIMAL (18, 2) CONSTRAINT [DF_Stationshifts_ShiftBalance] DEFAULT ((0)) NOT NULL,
    [ExpectedTankAmount] DECIMAL (18, 2) CONSTRAINT [DF_Stationshifts_ExpectedTankAmount] DEFAULT ((0)) NOT NULL,
    [ExpectedPumpAmount] DECIMAL (18, 2) CONSTRAINT [DF_Stationshifts_ExpectedPumpAmount] DEFAULT ((0)) NOT NULL,
    [GainLoss]           DECIMAL (18, 2) CONSTRAINT [DF_Stationshifts_GainLoss] DEFAULT ((0)) NOT NULL,
    [PercentGainLoss]    DECIMAL (18, 2) CONSTRAINT [DF_Stationshifts_PercentGainLoss] DEFAULT ((0)) NOT NULL,
    [ShiftBankReference] VARCHAR (200)   NULL,
    [ShiftReference]     VARCHAR (400)   NULL,
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
    PRIMARY KEY CLUSTERED ([ShiftId] ASC)
);






GO

GO
