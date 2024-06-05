CREATE TABLE [dbo].[EmployeeTransactionFrequency] (
    [EmployeeFrequencyId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [EmployeeId]          BIGINT       NOT NULL,
    [Frequency]           INT          NOT NULL,
    [FrequencyPeriod]     VARCHAR (40) NOT NULL,
    [IsActive]            BIT          DEFAULT ((1)) NOT NULL,
    [IsDeleted]           BIT          DEFAULT ((0)) NOT NULL,
    [CreatedBy]           BIGINT       NULL,
    [ModifiedBy]          BIGINT       NULL,
    [DateCreated]         DATETIME     NULL,
    [DateModified]        DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([EmployeeFrequencyId] ASC),
    FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[CustomerEmployees] ([EmployeeId]),
    FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[CustomerEmployees] ([EmployeeId])
);

