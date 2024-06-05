CREATE TABLE [dbo].[LnkStaffStation] (
    [UserId]    BIGINT NOT NULL,
    [StationId] BIGINT NOT NULL,
    FOREIGN KEY ([StationId]) REFERENCES [dbo].[SystemStations] ([StationId]),
    FOREIGN KEY ([UserId]) REFERENCES [dbo].[SystemStaffs] ([Userid])
);






GO

GO
