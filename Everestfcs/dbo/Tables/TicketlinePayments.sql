CREATE TABLE [dbo].[TicketlinePayments] (
    [PaymentId]     BIGINT          IDENTITY (1, 1) NOT NULL,
    [TicketId]      BIGINT          NOT NULL,
    [PaymentmodeId] BIGINT          NOT NULL,
    [TotalPaid]     DECIMAL (18, 2) NOT NULL,
    [TotalUsed]     DECIMAL (18, 2) NOT NULL,
    [MpesaCode]     VARCHAR (50)    NULL,
    [MpesaMSISDN]   VARCHAR (50)    NULL,
    [DateCreated]   DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([PaymentId] ASC),
    FOREIGN KEY ([PaymentmodeId]) REFERENCES [dbo].[Paymentmodes] ([PaymentmodeId]),
    FOREIGN KEY ([TicketId]) REFERENCES [dbo].[SystemTickets] ([TicketId])
);

