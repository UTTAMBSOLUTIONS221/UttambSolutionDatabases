CREATE TABLE [dbo].[PostpaidOneOffAgreements] (
    [PostpaidOneOffAgreementId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [AgreementId]               BIGINT          NOT NULL,
    [Amount]                    DECIMAL (18, 2) NOT NULL,
    [StartDate]                 DATETIME        NOT NULL,
    [DueDate]                   DATETIME        NOT NULL,
    [AvailableBalance]          DECIMAL (18, 2) NOT NULL,
    [GracePeriod]               INT             NOT NULL,
    [IsPaid]                    BIT             NOT NULL,
    [AgreementRef]              NVARCHAR (MAX)  NULL,
    [AgreementDocPath]          NVARCHAR (MAX)  NULL,
    [IsLPOExpired]              BIT             DEFAULT ((0)) NOT NULL,
    [DoesPayCloseLPO]           BIT             DEFAULT ((0)) NOT NULL,
    [IsActive]                  BIT             DEFAULT ((0)) NOT NULL,
    [IsDeleted]                 BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]                 BIGINT          NOT NULL,
    [Modifiedby]                BIGINT          NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [DateModified]              DATETIME        NULL,
    CONSTRAINT [PK_dbo.fmsPostpaidOneOffAgreements] PRIMARY KEY CLUSTERED ([PostpaidOneOffAgreementId] ASC)
);

