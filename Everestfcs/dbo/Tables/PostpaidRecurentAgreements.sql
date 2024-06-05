CREATE TABLE [dbo].[PostpaidRecurentAgreements] (
    [PostpaidRecurentAgreementId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [AgreementId]                 BIGINT          NOT NULL,
    [AllowedDebt]                 DECIMAL (18, 2) NOT NULL,
    [Balance]                     DECIMAL (18, 2) NOT NULL,
    [BillingCycleType]            VARCHAR (100)   NULL,
    [BillingCycle]                BIGINT          NOT NULL,
    [GracePeriod]                 INT             NOT NULL,
    [StartDate]                   DATETIME        NOT NULL,
    [PreviousBillingDate]         DATETIME        NULL,
    [NextBillingDate]             DATETIME        NULL,
    [IsActive]                    BIT             DEFAULT ((1)) NOT NULL,
    [IsDeleted]                   BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]                   BIGINT          NOT NULL,
    [Modifiedby]                  BIGINT          NOT NULL,
    [DateCreated]                 DATETIME        NOT NULL,
    [DateModified]                DATETIME        NULL,
    CONSTRAINT [PK_dbo.fmsPostpaidRecurentAgreements] PRIMARY KEY CLUSTERED ([PostpaidRecurentAgreementId] ASC),
    CONSTRAINT [FK_dbo.PostpaidRecurentAgreements_dbo.CustomerAgreements_AgreementId] FOREIGN KEY ([AgreementId]) REFERENCES [dbo].[CustomerAgreements] ([AgreementId]) ON DELETE CASCADE
);

