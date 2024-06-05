CREATE TABLE [dbo].[SystemCurrencies] (
    [CurrencyId]     BIGINT       IDENTITY (1, 1) NOT NULL,
    [CurrencyName]   VARCHAR (40) NOT NULL,
    [CurrencySymbol] VARCHAR (10) NOT NULL,
    PRIMARY KEY CLUSTERED ([CurrencyId] ASC)
);

