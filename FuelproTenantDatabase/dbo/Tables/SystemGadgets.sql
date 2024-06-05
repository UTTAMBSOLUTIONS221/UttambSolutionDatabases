CREATE TABLE [dbo].[SystemGadgets] (
    [GadgetId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [GadgetName]     VARCHAR (100) NOT NULL,
    [TenantgadgetId] BIGINT        NOT NULL,
    PRIMARY KEY CLUSTERED ([GadgetId] ASC),
    UNIQUE NONCLUSTERED ([TenantgadgetId] ASC)
);

