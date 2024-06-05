CREATE TABLE [dbo].[LSRuleDays] (
    [LSRuleDayId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [LSchemeRuleId] BIGINT        NOT NULL,
    [DaysofWeek]    VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([LSRuleDayId] ASC)
);

