CREATE TABLE [dbo].[ConsumLimitType] (
    [LimitTypeId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [LimitTypename] VARCHAR (100) NOT NULL,
    [Limitkey]      INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([LimitTypeId] ASC),
    UNIQUE NONCLUSTERED ([Limitkey] ASC),
    UNIQUE NONCLUSTERED ([LimitTypename] ASC)
);

