CREATE TABLE [dbo].[Payments] (
    [Paymentid]   INT             IDENTITY (1, 1) NOT NULL,
    [ServiceCode] VARCHAR (15)    NOT NULL,
    [PaymentRef]  VARCHAR (15)    NOT NULL,
    [AccountNo]   VARCHAR (20)    NOT NULL,
    [AccountName] VARCHAR (35)    NULL,
    [Amount]      DECIMAL (18, 2) NOT NULL,
    [PDate]       DATETIME        NOT NULL,
    [PType]       INT             DEFAULT ((0)) NOT NULL,
    [PStatus]     INT             DEFAULT ((0)) NOT NULL,
    [TPRef]       VARCHAR (15)    NULL,
    [RespNo]      VARCHAR (15)    NULL,
    [RespMsg]     VARCHAR (250)   NULL,
    [ExtRef]      VARCHAR (50)    NULL,
    [Extra1]      VARCHAR (100)   NULL,
    [Extra2]      VARCHAR (100)   NULL,
    [Extra3]      VARCHAR (100)   NULL,
    [Extra4]      VARCHAR (100)   NULL,
    [TPStat]      INT             DEFAULT ((0)) NOT NULL,
    [TPMessage]   VARCHAR (150)   NULL,
    CONSTRAINT [pk_Payments] PRIMARY KEY CLUSTERED ([Paymentid] ASC)
);

