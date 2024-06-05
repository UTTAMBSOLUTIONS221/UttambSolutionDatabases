CREATE TABLE [dbo].[Systemloandetailitems] (
    [Loandetailitemid] BIGINT          IDENTITY (1, 1) NOT NULL,
    [Loandetailid]     BIGINT          NOT NULL,
    [Customerid]       BIGINT          NOT NULL,
    [Period]           BIGINT          NOT NULL,
    [Paymentdate]      DATETIME        NOT NULL,
    [Paymentamount]    DECIMAL (18, 2) NOT NULL,
    [Currentbalance]   DECIMAL (18, 2) NOT NULL,
    [Interestamount]   DECIMAL (18, 2) NOT NULL,
    [Principalamount]  DECIMAL (18, 2) NOT NULL,
    [Paymentstatus]    INT             DEFAULT ((3)) NOT NULL,
    [Payementreason]   VARCHAR (100)   NOT NULL,
    [Extra1]           VARCHAR (100)   NULL,
    [Extra2]           VARCHAR (100)   NULL,
    [Extra3]           VARCHAR (100)   NULL,
    [Extra4]           VARCHAR (100)   NULL,
    [Extra5]           VARCHAR (100)   NULL,
    PRIMARY KEY CLUSTERED ([Loandetailitemid] ASC),
    FOREIGN KEY ([Customerid]) REFERENCES [dbo].[Systemcustomers] ([Customerid]),
    FOREIGN KEY ([Loandetailid]) REFERENCES [dbo].[Systemloandetail] ([Loandetailid])
);

