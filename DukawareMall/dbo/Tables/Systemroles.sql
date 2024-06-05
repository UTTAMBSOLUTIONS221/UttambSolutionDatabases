CREATE TABLE [dbo].[Systemroles] (
    [Roleid]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [Rolename]        VARCHAR (100) NOT NULL,
    [RoleDescription] VARCHAR (300) NULL,
    [Isdefault]       BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Roleid] ASC)
);

