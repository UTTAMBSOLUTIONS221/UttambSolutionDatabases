CREATE TABLE [dbo].[LSRulePaymentModes] (
    [LSRulePaymentModeId] BIGINT IDENTITY (1, 1) NOT NULL,
    [LSchemeRuleId]       BIGINT NOT NULL,
    [PaymentModeId]       BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED ([LSRulePaymentModeId] ASC)
);

