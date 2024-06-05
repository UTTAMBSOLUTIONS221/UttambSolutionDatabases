CREATE TABLE [dbo].[Loanidaccountid] (
    [Accountid]    BIGINT NOT NULL,
    [Loandetailid] BIGINT NOT NULL,
    FOREIGN KEY ([Accountid]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([Loandetailid]) REFERENCES [dbo].[Systemloandetail] ([Loandetailid])
);

