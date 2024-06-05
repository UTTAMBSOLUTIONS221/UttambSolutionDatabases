CREATE TABLE [dbo].[Tenantroleperms] (
    [RoleId]       BIGINT NOT NULL,
    [PermissionId] BIGINT NOT NULL,
    FOREIGN KEY ([PermissionId]) REFERENCES [dbo].[Tenantpermissions] ([PermissionId]),
    FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Tenantroles] ([Roleid])
);

