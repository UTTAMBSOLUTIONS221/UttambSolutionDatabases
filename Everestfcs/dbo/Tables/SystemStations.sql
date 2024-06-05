﻿CREATE TABLE [dbo].[SystemStations] (
    [StationId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [Tenantid]     BIGINT        NOT NULL,
    [Sname]        VARCHAR (100) NOT NULL,
    [Semail]       VARCHAR (100) NOT NULL,
    [Phoneid]      BIGINT        NOT NULL,
    [Phone]        VARCHAR (15)  NOT NULL,
    [Addresses]    VARCHAR (100) NULL,
    [City]         VARCHAR (100) NULL,
    [Street]       VARCHAR (100) NULL,
    [IsDefault]    BIT           DEFAULT ((0)) NOT NULL,
    [IsActive]     BIT           DEFAULT ((1)) NOT NULL,
    [IsDeleted]    BIT           DEFAULT ((0)) NOT NULL,
    [Extra]        BIT           CONSTRAINT [DF_Extra] DEFAULT ((0)) NOT NULL,
    [Extra1]       VARCHAR (100) NULL,
    [Extra2]       VARCHAR (100) NULL,
    [Extra3]       VARCHAR (100) NULL,
    [Extra4]       VARCHAR (100) NULL,
    [Extra5]       VARCHAR (100) NULL,
    [Extra6]       VARCHAR (100) NULL,
    [Extra7]       VARCHAR (100) NULL,
    [Extra8]       VARCHAR (100) NULL,
    [Extra9]       VARCHAR (100) NULL,
    [Createdby]    BIGINT        NULL,
    [Modifiedby]   BIGINT        NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [DateModified] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([StationId] ASC),
    FOREIGN KEY ([Tenantid]) REFERENCES [dbo].[Tenantaccounts] ([Tenantid])
);








GO

GO

GO

GO
