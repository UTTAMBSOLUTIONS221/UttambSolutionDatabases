CREATE TABLE [dbo].[AccountEmployee] (
    [AccountId]  BIGINT NOT NULL,
    [EmployeeId] BIGINT NOT NULL,
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([AccountId]) REFERENCES [dbo].[CustomerAccount] ([AccountId]),
    FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[CustomerEmployees] ([EmployeeId]),
    FOREIGN KEY ([EmployeeId]) REFERENCES [dbo].[CustomerEmployees] ([EmployeeId])
);



