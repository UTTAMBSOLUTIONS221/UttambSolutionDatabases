CREATE TABLE [dbo].[CustomerAccount] (
    [AccountId]         BIGINT          IDENTITY (1, 1) NOT NULL,
    [AgreementId]       BIGINT          NOT NULL,
    [AccountNumber]     BIGINT          NOT NULL,
    [AccountCode]       VARCHAR (50)    DEFAULT ('0') NOT NULL,
    [GroupingId]        BIGINT          NOT NULL,
    [ParentId]          BIGINT          NOT NULL,
    [CredittypeId]      BIGINT          NOT NULL,
    [LimitTypeId]       BIGINT          NOT NULL,
    [ConsumptionLimit]  DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ConsumptionPeriod] VARCHAR (50)    DEFAULT ('Monthly') NOT NULL,
    [Isadminactive]     BIT             NOT NULL,
    [Iscustomeractive]  BIT             NOT NULL,
    [IsActive]          BIT             NOT NULL,
    [IsDeleted]         BIT             NOT NULL,
    [Createdby]         BIGINT          NULL,
    [Modifiedby]        BIGINT          NULL,
    [Datecreated]       DATETIME        NULL,
    [Datemodified]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([AccountId] ASC),
    UNIQUE NONCLUSTERED ([AccountNumber] ASC)
);

