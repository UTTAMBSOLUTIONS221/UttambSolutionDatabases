CREATE TABLE [dbo].[LSRuleProducts] (
    [LSRuleProductId]    BIGINT IDENTITY (1, 1) NOT NULL,
    [LSchemeRuleId]      BIGINT NOT NULL,
    [ProductvariationId] BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED ([LSRuleProductId] ASC)
);

