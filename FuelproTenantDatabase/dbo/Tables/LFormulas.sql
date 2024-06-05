CREATE TABLE [dbo].[LFormulas] (
    [FormulaId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [FormulaName]  VARCHAR (100) NOT NULL,
    [ValueType]    VARCHAR (20)  NOT NULL,
    [Createdby]    BIGINT        NOT NULL,
    [Modifiedby]   BIGINT        NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [DateModified] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([FormulaId] ASC)
);

