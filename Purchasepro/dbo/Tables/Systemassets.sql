CREATE TABLE [dbo].[Systemassets] (
    [Assetid]      BIGINT        IDENTITY (1, 1) NOT NULL,
    [Assetname]    VARCHAR (100) NOT NULL,
    [Extra]        VARCHAR (100) NULL,
    [Extra1]       VARCHAR (100) NULL,
    [Extra2]       VARCHAR (100) NULL,
    [Extra3]       VARCHAR (100) NULL,
    [Extra4]       VARCHAR (100) NULL,
    [Extra5]       VARCHAR (100) NULL,
    [Extra6]       VARCHAR (100) NULL,
    [Extra7]       VARCHAR (100) NULL,
    [Extra8]       VARCHAR (100) NULL,
    [Extra9]       VARCHAR (100) NULL,
    [Extra10]      VARCHAR (100) NULL,
    [Isactive]     BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]    BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]    BIGINT        NOT NULL,
    [Modifiedby]   BIGINT        NOT NULL,
    [Datemodified] DATETIME      NOT NULL,
    [Datecreated]  DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([Assetid] ASC),
    UNIQUE NONCLUSTERED ([Assetname] ASC)
);

