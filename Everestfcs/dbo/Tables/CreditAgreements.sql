CREATE TABLE [dbo].[CreditAgreements] (
    [CreditAgreementtId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [AgreementId]        BIGINT          NOT NULL,
    [CreditLimit]        DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [Paymentterms]       INT             DEFAULT ((0)) NOT NULL,
    [LimitTypeId]        BIGINT          NOT NULL,
    [AllowCredit]        BIT             DEFAULT ((0)) NOT NULL,
    [AllowedCredit]      DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [AutoAprovepo]       BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]          BIGINT          NULL,
    [Modifiedby]         BIGINT          NULL,
    [Datecreated]        DATETIME        NULL,
    [Datemodified]       DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([CreditAgreementtId] ASC),
    FOREIGN KEY ([AgreementId]) REFERENCES [dbo].[CustomerAgreements] ([AgreementId]),
    FOREIGN KEY ([LimitTypeId]) REFERENCES [dbo].[ConsumLimitType] ([LimitTypeId])
);

