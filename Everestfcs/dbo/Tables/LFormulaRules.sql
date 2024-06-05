CREATE TABLE [dbo].[LFormulaRules] (
    [FormulaRuleId]     BIGINT          IDENTITY (1, 1) NOT NULL,
    [FormulaId]         BIGINT          NOT NULL,
    [Range1]            DECIMAL (10, 3) NOT NULL,
    [Range2]            DECIMAL (10, 3) NOT NULL,
    [IsRangetoInfinity] BIT             DEFAULT ((0)) NOT NULL,
    [Formula]           VARCHAR (100)   NOT NULL,
    [IsApproved]        BIT             DEFAULT ((0)) NOT NULL,
    [ApprovalLevel]     VARCHAR (40)    DEFAULT ('Pending') NOT NULL,
    [Createdby]         BIGINT          NOT NULL,
    [Modifiedby]        BIGINT          NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [DateModified]      DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([FormulaRuleId] ASC)
);

