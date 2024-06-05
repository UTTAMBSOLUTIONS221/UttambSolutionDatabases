CREATE TABLE [dbo].[ProductUoms] (
    [Uomid]        BIGINT       IDENTITY (1, 1) NOT NULL,
    [Uomname]      VARCHAR (40) NOT NULL,
    [Createdby]    BIGINT       NOT NULL,
    [Modifiedby]   BIGINT       NOT NULL,
    [Datecreated]  DATETIME     NOT NULL,
    [DateModified] DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([Uomid] ASC)
);

