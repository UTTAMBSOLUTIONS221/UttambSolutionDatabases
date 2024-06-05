CREATE TABLE [dbo].[Mpesanotificationlogs] (
    [Mpesanotificationid] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Action]              NVARCHAR (50)   NULL,
    [IsTxnSuccessFull]    BIT             NOT NULL,
    [DateCreated]         DATETIME        NOT NULL,
    [TransactionType]     NVARCHAR (50)   NULL,
    [TransID]             NVARCHAR (200)  NULL,
    [TransTime]           NVARCHAR (100)  NULL,
    [TransAmount]         DECIMAL (18, 2) NULL,
    [BusinessShortCode]   NVARCHAR (50)   NULL,
    [BillRefNumber]       NVARCHAR (50)   NULL,
    [InvoiceNumber]       VARCHAR (50)    NULL,
    [OrgAccountBalance]   DECIMAL (18, 2) NULL,
    [ThirdPartyTransId]   VARCHAR (50)    NULL,
    [MSISDN]              VARCHAR (50)    NULL,
    [FirstName]           VARCHAR (50)    NULL,
    [MiddleName]          VARCHAR (50)    NULL,
    [LastName]            VARCHAR (50)    NULL,
    [TxnErrorMsg]         NVARCHAR (MAX)  NULL,
    CONSTRAINT [pk_MpesaNotificationLogs_id] PRIMARY KEY CLUSTERED ([Mpesanotificationid] ASC)
);

