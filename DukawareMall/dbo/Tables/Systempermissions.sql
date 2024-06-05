CREATE TABLE [dbo].[Systempermissions] (
    [PermissionId]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [Permissionname] VARCHAR (70) NOT NULL,
    [Isactive]       BIT          DEFAULT ((1)) NOT NULL,
    [Isdeleted]      BIT          DEFAULT ((0)) NOT NULL,
    [Module]         INT          NOT NULL,
    [IsAdmin]        BIT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([PermissionId] ASC)
);



