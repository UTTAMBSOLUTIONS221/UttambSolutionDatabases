CREATE TABLE [dbo].[LSRuleLoyaltyGrouping] (
    [LSRuleGroupingId] BIGINT IDENTITY (1, 1) NOT NULL,
    [LSchemeRuleId]    BIGINT NOT NULL,
    [GroupingId]       BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED ([LSRuleGroupingId] ASC)
);

