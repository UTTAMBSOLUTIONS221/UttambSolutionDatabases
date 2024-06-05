CREATE TABLE [dbo].[Systemproductdescription] (
    [DescriptionId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [SystemproductId] BIGINT        NOT NULL,
    [Descriptiondata] VARCHAR (800) NOT NULL,
    [Isactive]        BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]       BIT           DEFAULT ((0)) NOT NULL,
    [Createdby]       BIGINT        NOT NULL,
    [Modifiedby]      BIGINT        NOT NULL,
    [Datemodified]    DATETIME      NOT NULL,
    [Datecreated]     DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([DescriptionId] ASC),
    FOREIGN KEY ([SystemproductId]) REFERENCES [dbo].[Systemproduct] ([SystemproductId])
);

