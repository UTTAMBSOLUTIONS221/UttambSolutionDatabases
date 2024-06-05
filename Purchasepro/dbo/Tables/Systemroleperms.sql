CREATE TABLE [dbo].[Systemroleperms] (
    [RoleId]       BIGINT NOT NULL,
    [PermissionId] BIGINT NOT NULL,
    FOREIGN KEY ([PermissionId]) REFERENCES [dbo].[Systempermissions] ([PermissionId]),
    FOREIGN KEY ([PermissionId]) REFERENCES [dbo].[Systempermissions] ([PermissionId]),
    FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Systemroles] ([Roleid]),
    FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Systemroles] ([Roleid])
);

