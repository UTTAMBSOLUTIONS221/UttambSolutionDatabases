CREATE TABLE [dbo].[Systemcard] (
    [CardId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [TenantId]     BIGINT        NOT NULL,
    [CardUID]      VARCHAR (50)  NOT NULL,
    [CardSNO]      VARCHAR (50)  NOT NULL,
    [PIN]          VARCHAR (100) NULL,
    [PinHarsh]     VARCHAR (100) NULL,
    [CardCode]     VARCHAR (100) NULL,
    [IsActive]     BIT           DEFAULT ((1)) NOT NULL,
    [IsDeleted]    BIT           DEFAULT ((0)) NOT NULL,
    [IsAssigned]   BIT           DEFAULT ((0)) NOT NULL,
    [IsReplaced]   BIT           DEFAULT ((0)) NOT NULL,
    [TagtypeId]    BIGINT        DEFAULT ((0)) NOT NULL,
    [Createdby]    BIGINT        NULL,
    [Modifiedby]   BIGINT        NULL,
    [Datecreated]  DATETIME      NULL,
    [Datemodified] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CardId] ASC),
    FOREIGN KEY ([TagtypeId]) REFERENCES [dbo].[Systemcardtype] ([TagtypeId]),
    FOREIGN KEY ([TagtypeId]) REFERENCES [dbo].[Systemcardtype] ([TagtypeId])
);

