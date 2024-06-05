CREATE TABLE [dbo].[Systemproductspecification] (
    [SpecificationId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [SystemproductId]   BIGINT        NOT NULL,
    [Specificationdata] VARCHAR (800) NOT NULL,
    [Isactive]          BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]         BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]         BIGINT        NOT NULL,
    [Modifiedby]        BIGINT        NOT NULL,
    [Datemodified]      DATETIME      NOT NULL,
    [Datecreated]       DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([SpecificationId] ASC),
    FOREIGN KEY ([SystemproductId]) REFERENCES [dbo].[Systemproduct] ([SystemproductId])
);

