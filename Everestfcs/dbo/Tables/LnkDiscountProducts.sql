CREATE TABLE [dbo].[LnkDiscountProducts] (
    [LnkDiscountProductId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [DiscountlistId]       BIGINT          NOT NULL,
    [ProductvariationId]   BIGINT          NOT NULL,
    [StationId]            BIGINT          NOT NULL,
    [Discountvalue]        DECIMAL (10, 2) NOT NULL,
    [Daysapplicable]       VARCHAR (100)   NOT NULL,
    [Starttime]            VARCHAR (40)    NOT NULL,
    [Endtime]              VARCHAR (40)    NOT NULL,
    [Createdby]            BIGINT          NOT NULL,
    [Modifiedby]           BIGINT          NOT NULL,
    [Datecreated]          DATETIME        NOT NULL,
    [Datemodified]         DATETIME        NOT NULL,
    [Discounttype]         VARCHAR (40)    DEFAULT ('Absolute') NOT NULL,
    PRIMARY KEY CLUSTERED ([LnkDiscountProductId] ASC)
);

