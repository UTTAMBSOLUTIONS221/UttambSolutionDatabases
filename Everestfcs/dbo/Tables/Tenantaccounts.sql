CREATE TABLE [dbo].[Tenantaccounts] (
    [Tenantid]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [Countryid]           BIGINT        NOT NULL,
    [Tenantname]          VARCHAR (100) NOT NULL,
    [Tenantsubdomain]     VARCHAR (70)  NOT NULL,
    [TenantLogo]          VARCHAR (200) NULL,
    [TenantEmail]         VARCHAR (100) NULL,
    [Phoneid]             BIGINT        NOT NULL,
    [Phonenumber]         VARCHAR (12)  NOT NULL,
    [TenantReference]     VARCHAR (100) NULL,
    [TenantPIN]           VARCHAR (100) NULL,
    [IsCCEmail]           BIT           NOT NULL,
    [CCEmail]             VARCHAR (50)  NULL,
    [StaffAutoLogOff]     BIT           NOT NULL,
    [EmailServer]         VARCHAR (200) NULL,
    [EmailAddress]        VARCHAR (200) NULL,
    [EmailPassword]       VARCHAR (200) NULL,
    [MessageUrl]          VARCHAR (200) NULL,
    [Messageusername]     VARCHAR (200) NULL,
    [Messageapikey]       VARCHAR (200) NULL,
    [ApplyTax]            BIT           NOT NULL,
    [NoOfDecimalPlaces]   INT           NULL,
    [IsEmailEnabled]      BIT           NOT NULL,
    [IsSmsEnabled]        BIT           NOT NULL,
    [IsTemplateTrancated] BIT           NOT NULL,
    [Extra]               VARCHAR (100) NULL,
    [Extra1]              VARCHAR (100) NULL,
    [Extra2]              VARCHAR (100) NULL,
    [Extra3]              VARCHAR (100) NULL,
    [Extra4]              VARCHAR (100) NULL,
    [Extra5]              VARCHAR (100) NULL,
    [Extra6]              VARCHAR (100) NULL,
    [Extra7]              VARCHAR (100) NULL,
    [Extra8]              VARCHAR (100) NULL,
    [Extra9]              VARCHAR (100) NULL,
    [Extra10]             VARCHAR (100) NULL,
    [Tenantloginstatus]   BIGINT        DEFAULT ((0)) NOT NULL,
    [Isactive]            BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]           BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]           BIGINT        NULL,
    [Modifiedby]          BIGINT        NULL,
    [DateCreated]         DATETIME      DEFAULT (getdate()) NOT NULL,
    [DateModified]        DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Tenantid] ASC),
    UNIQUE NONCLUSTERED ([Tenantname] ASC),
    UNIQUE NONCLUSTERED ([Tenantsubdomain] ASC)
);






GO

GO

GO

GO
