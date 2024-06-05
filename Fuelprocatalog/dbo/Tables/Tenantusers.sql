﻿CREATE TABLE [dbo].[Tenantusers] (
    [Userid]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [Tenantid]          BIGINT          NOT NULL,
    [Firstname]         VARCHAR (70)    NOT NULL,
    [Lastname]          VARCHAR (70)    NOT NULL,
    [Phoneid]           BIGINT          NOT NULL,
    [Phonenumber]       VARCHAR (12)    NOT NULL,
    [Username]          VARCHAR (100)   NOT NULL,
    [Emailaddress]      VARCHAR (100)   NOT NULL,
    [Roleid]            BIGINT          NOT NULL,
    [Passharsh]         VARCHAR (100)   NOT NULL,
    [Passwords]         VARCHAR (100)   NOT NULL,
    [LimitTypeId]       BIGINT          NULL,
    [LimitTypeValue]    DECIMAL (18, 2) NULL,
    [Isactive]          BIT             NOT NULL,
    [Isdeleted]         BIT             DEFAULT ((0)) NOT NULL,
    [Loginstatus]       INT             DEFAULT ((2)) NOT NULL,
    [Passwordresetdate] DATETIME        NOT NULL,
    [Parentid]          BIGINT          NOT NULL DEFAULT (0),
    [Extra]             VARCHAR (100)   NULL,
    [Extra1]            VARCHAR (100)   NULL,
    [Extra2]            VARCHAR (100)   NULL,
    [Extra3]            VARCHAR (100)   NULL,
    [Extra4]            VARCHAR (100)   NULL,
    [Extra5]            VARCHAR (100)   NULL,
    [Createdby]         BIGINT          NOT NULL,
    [Modifiedby]        BIGINT          NOT NULL,
    [Lastlogin]         DATETIME        NOT NULL,
    [Datemodified]      DATETIME        NOT NULL,
    [Datecreated]       DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([Userid] ASC),
    FOREIGN KEY ([Phoneid]) REFERENCES [dbo].[SystemPhoneCodes] ([Phoneid]),
    FOREIGN KEY ([Roleid]) REFERENCES [dbo].[Tenantroles] ([Roleid]),
    FOREIGN KEY ([Tenantid]) REFERENCES [dbo].[Tenantaccounts] ([Tenantid])
);







