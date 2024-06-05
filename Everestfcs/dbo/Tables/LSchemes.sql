CREATE TABLE [dbo].[LSchemes] (
    [LSchemeId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [Tenantid]     BIGINT        NOT NULL,
    [LSchemeName]  VARCHAR (100) NOT NULL,
    [StartDate]    DATETIME      NOT NULL,
    [EndDate]      DATETIME      NOT NULL,
    [IsActive]     BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]    BIGINT        NOT NULL,
    [Modifiedby]   BIGINT        NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [DateModified] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([LSchemeId] ASC)
);

