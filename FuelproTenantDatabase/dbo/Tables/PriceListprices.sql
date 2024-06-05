CREATE TABLE [dbo].[PriceListprices] (
    [PriceListPricesId]  BIGINT          IDENTITY (1, 1) NOT NULL,
    [PriceListId]        BIGINT          NOT NULL,
    [StationId]          BIGINT          NOT NULL,
    [ProductvariationId] BIGINT          NOT NULL,
    [ProductPrice]       DECIMAL (18, 2) NOT NULL,
    PRIMARY KEY CLUSTERED ([PriceListPricesId] ASC),
    FOREIGN KEY ([PriceListId]) REFERENCES [dbo].[PriceList] ([PriceListId]),
    FOREIGN KEY ([PriceListId]) REFERENCES [dbo].[PriceList] ([PriceListId]),
    FOREIGN KEY ([ProductvariationId]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId]),
    FOREIGN KEY ([ProductvariationId]) REFERENCES [dbo].[SystemProductvariation] ([ProductvariationId]),
    CONSTRAINT [FK__PriceList__Stati__4C364F0E] FOREIGN KEY ([StationId]) REFERENCES [dbo].[SystemStations] ([Tenantstationid]),
    CONSTRAINT [FK__PriceList__Stati__77DFC722] FOREIGN KEY ([StationId]) REFERENCES [dbo].[SystemStations] ([Tenantstationid])
);



