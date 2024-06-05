CREATE TABLE [dbo].[CreditTypes] (
    [CredittypeId]    BIGINT       IDENTITY (1, 1) NOT NULL,
    [Credittypename]  VARCHAR (40) NOT NULL,
    [Credittypevalue] INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([CredittypeId] ASC)
);

