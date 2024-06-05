CREATE TABLE [dbo].[Paymentmodes] (
    [PaymentmodeId]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [Paymentmode]       VARCHAR (100) NOT NULL,
    [PaymentmodetypeId] BIGINT        NOT NULL,
    [IsposAccepted]     BIT           DEFAULT ((0)) NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([PaymentmodeId] ASC),
    FOREIGN KEY ([PaymentmodetypeId]) REFERENCES [dbo].[Paymentmodetypes] ([PaymentmodetypeId]),
    FOREIGN KEY ([PaymentmodetypeId]) REFERENCES [dbo].[Paymentmodetypes] ([PaymentmodetypeId])
);



