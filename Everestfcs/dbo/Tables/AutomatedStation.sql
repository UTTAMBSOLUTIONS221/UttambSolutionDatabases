CREATE TABLE [dbo].[AutomatedStation] (
    [AutomatedStationId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [TenantId]           BIGINT       NOT NULL,
    [StationId]          BIGINT       NOT NULL,
    [Stationcode]        VARCHAR (20) NOT NULL,
    [Isautomated]        BIT          DEFAULT ((0)) NOT NULL,
    [Automatedby]        BIGINT       NOT NULL,
    [DateAutomated]      DATETIME     DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([AutomatedStationId] ASC),
    UNIQUE NONCLUSTERED ([Stationcode] ASC)
);

