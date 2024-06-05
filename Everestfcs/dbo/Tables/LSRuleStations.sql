CREATE TABLE [dbo].[LSRuleStations] (
    [LSRuleStationId] BIGINT IDENTITY (1, 1) NOT NULL,
    [LSchemeRuleId]   BIGINT NOT NULL,
    [StationId]       BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED ([LSRuleStationId] ASC)
);

