CREATE TABLE [dbo].[Systemroles] (
    [Roleid]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [Rolename]        VARCHAR (100) NOT NULL,
    [RoleDescription] VARCHAR (300) NULL,
    [Tenantid]        BIGINT        NOT NULL,
    [Isdefault]       BIT           DEFAULT ((0)) NOT NULL,
    [Isactive]        BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]       BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]       BIGINT        NOT NULL,
    [Modifiedby]      BIGINT        NOT NULL,
    [Datemodified]    DATETIME      NOT NULL,
    [Datecreated]     DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([Roleid] ASC),
    FOREIGN KEY ([Tenantid]) REFERENCES [dbo].[Tenantaccounts] ([Tenantid])
);

