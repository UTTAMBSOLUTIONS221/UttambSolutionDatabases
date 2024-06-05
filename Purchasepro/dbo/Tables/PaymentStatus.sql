CREATE TABLE [dbo].[PaymentStatus] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [StatusCode] INT          NOT NULL,
    [Descr]      VARCHAR (20) NOT NULL,
    CONSTRAINT [pk_PaymentStatus] PRIMARY KEY CLUSTERED ([Id] ASC)
);

