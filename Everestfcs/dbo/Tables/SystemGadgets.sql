CREATE TABLE [dbo].[SystemGadgets] (
    [GadgetId]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [Tenantid]     BIGINT        NOT NULL,
    [GadgetName]   VARCHAR (100) NOT NULL,
    [Descriptions] VARCHAR (100) NOT NULL,
    [Imei1]        VARCHAR (100) NULL,
    [Imei12]       VARCHAR (100) NULL,
    [Serialnumber] VARCHAR (100) NULL,
    [IsActive]     BIT           DEFAULT ((1)) NOT NULL,
    [IsDeleted]    BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]    BIGINT        NULL,
    [Modifiedby]   BIGINT        NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [DateModified] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([GadgetId] ASC),
    UNIQUE NONCLUSTERED ([GadgetName] ASC),
    UNIQUE NONCLUSTERED ([Imei1] ASC),
    UNIQUE NONCLUSTERED ([Imei12] ASC),
    UNIQUE NONCLUSTERED ([Serialnumber] ASC)
);

