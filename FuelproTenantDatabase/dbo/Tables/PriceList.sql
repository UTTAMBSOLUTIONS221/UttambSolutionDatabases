CREATE TABLE [dbo].[PriceList] (
    [PriceListId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [PriceListname] VARCHAR (100) NOT NULL,
    [IsDefault]     BIT           DEFAULT ((0)) NOT NULL,
    [IsActive]      BIT           DEFAULT ((1)) NOT NULL,
    [IsDeleted]     BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]     BIGINT        NULL,
    [Modifiedby]    BIGINT        NULL,
    [Datecreated]   DATETIME      NULL,
    [Datemodified]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([PriceListId] ASC),
    UNIQUE NONCLUSTERED ([PriceListname] ASC)
);

