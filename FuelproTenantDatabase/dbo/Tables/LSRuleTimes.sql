CREATE TABLE [dbo].[LSRuleTimes] (
    [LSRuleTimeId]  BIGINT       IDENTITY (1, 1) NOT NULL,
    [LSchemeRuleId] BIGINT       NOT NULL,
    [StartTime]     VARCHAR (10) NOT NULL,
    [EndTime]       VARCHAR (10) NOT NULL,
    PRIMARY KEY CLUSTERED ([LSRuleTimeId] ASC)
);

