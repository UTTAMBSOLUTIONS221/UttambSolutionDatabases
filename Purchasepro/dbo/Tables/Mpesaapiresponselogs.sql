CREATE TABLE [dbo].[Mpesaapiresponselogs] (
    [Mpesaapiresponseid] BIGINT         IDENTITY (1, 1) NOT NULL,
    [IsTxnSuccessFull]   BIT            NOT NULL,
    [Action]             NVARCHAR (50)  NULL,
    [StatusCode]         NVARCHAR (50)  NOT NULL,
    [Response]           NVARCHAR (MAX) NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    CONSTRAINT [pk_MpesaAPIResponseLogs_id] PRIMARY KEY CLUSTERED ([Mpesaapiresponseid] ASC)
);

