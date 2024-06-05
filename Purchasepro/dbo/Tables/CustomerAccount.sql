CREATE TABLE [dbo].[CustomerAccount] (
    [AccountId]     BIGINT   IDENTITY (1, 1) NOT NULL,
    [CustomerId]    BIGINT   NOT NULL,
    [AccountNumber] BIGINT   NOT NULL,
    [IsActive]      BIT      NOT NULL,
    [IsDeleted]     BIT      NOT NULL,
    [Createdby]     BIGINT   NULL,
    [Datecreated]   DATETIME NULL,
    PRIMARY KEY CLUSTERED ([AccountId] ASC),
    FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Systemcustomers] ([Customerid]),
    UNIQUE NONCLUSTERED ([AccountNumber] ASC)
);

