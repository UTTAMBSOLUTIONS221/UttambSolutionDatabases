CREATE TABLE [dbo].[LSchemeRules] (
    [LSchemeRuleId]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [LSchemeId]              BIGINT        NOT NULL,
    [FormulaId]              BIGINT        NOT NULL,
    [LRewardId]              BIGINT        NOT NULL,
    [CalculateProdOrPaymode] VARCHAR (100) CONSTRAINT [DF_LSchemeRules_CalculateProdOrPaymode] DEFAULT ('Product') NOT NULL,
    [IsActive]               BIT           DEFAULT ((0)) NOT NULL,
    [IsApproved]             BIT           DEFAULT ((0)) NOT NULL,
    [ApprovalLevel]          VARCHAR (40)  DEFAULT ('Pending') NOT NULL,
    [Createdby]              BIGINT        NOT NULL,
    [Modifiedby]             BIGINT        NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [DateModified]           DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([LSchemeRuleId] ASC)
);

