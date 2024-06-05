CREATE TABLE [dbo].[Stationshifts] (
    [ShiftId]      BIGINT       IDENTITY (1, 1) NOT NULL,
    [StationId]    BIGINT       NOT NULL,
    [Shiftname]    VARCHAR (20) NOT NULL,
    [Starttime]    VARCHAR (20) NOT NULL,
    [Endtime]      VARCHAR (20) NOT NULL,
    [Isactive]     BIT          DEFAULT ((1)) NOT NULL,
    [Isdeleted]    BIT          DEFAULT ((0)) NOT NULL,
    [Createdby]    BIGINT       NOT NULL,
    [Modifiedby]   BIGINT       NOT NULL,
    [Datecreated]  DATETIME     NOT NULL,
    [Datemodified] DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([ShiftId] ASC)
);

