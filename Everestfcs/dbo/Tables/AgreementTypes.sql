CREATE TABLE [dbo].[AgreementTypes] (
    [AgreemettypeId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [Agreementtypename] VARCHAR (100) NOT NULL,
    [LimitTypeId]       BIGINT        NOT NULL,
    PRIMARY KEY CLUSTERED ([AgreemettypeId] ASC),
    FOREIGN KEY ([LimitTypeId]) REFERENCES [dbo].[ConsumLimitType] ([LimitTypeId]),
    FOREIGN KEY ([LimitTypeId]) REFERENCES [dbo].[ConsumLimitType] ([LimitTypeId]),
    UNIQUE NONCLUSTERED ([Agreementtypename] ASC)
);

