CREATE TABLE [dbo].[SystemStaffs] (
    [StaffId]  BIGINT       IDENTITY (1, 1) NOT NULL,
    [Fullname] VARCHAR (50) NOT NULL,
    [UserId]   BIGINT       NOT NULL,
    PRIMARY KEY CLUSTERED ([StaffId] ASC),
    CONSTRAINT [UniqueKeyUserId] UNIQUE NONCLUSTERED ([UserId] ASC)
);





