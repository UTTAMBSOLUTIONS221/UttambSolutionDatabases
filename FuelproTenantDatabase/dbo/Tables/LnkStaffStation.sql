CREATE TABLE [dbo].[LnkStaffStation] (
    [UserId]    BIGINT NOT NULL,
    [StationId] BIGINT NOT NULL,
    FOREIGN KEY ([StationId]) REFERENCES [dbo].[SystemStations] ([Tenantstationid]),
    FOREIGN KEY ([UserId]) REFERENCES [dbo].[SystemStaffs] ([UserId])
);

