CREATE TABLE [dbo].[Paymentmodetypes] (
    [PaymentmodetypeId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Paymentmodetype]   VARCHAR (100) NOT NULL,
    [Descriptions]      VARCHAR (100) NULL,
    [DateCreated]       DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([PaymentmodetypeId] ASC)
);

