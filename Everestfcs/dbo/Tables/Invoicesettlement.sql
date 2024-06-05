CREATE TABLE [dbo].[Invoicesettlement] (
    [InvoicepaymentId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [PaymentId]        BIGINT          NOT NULL,
    [InvoiceId]        BIGINT          NOT NULL,
    [Amountused]       DECIMAL (18, 2) NOT NULL,
    [Datesettled]      DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([InvoicepaymentId] ASC)
);

