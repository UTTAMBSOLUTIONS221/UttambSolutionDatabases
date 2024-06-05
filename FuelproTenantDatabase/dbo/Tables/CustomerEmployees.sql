CREATE TABLE [dbo].[CustomerEmployees] (
    [EmployeeId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [Firstname]    VARCHAR (70)  NOT NULL,
    [Lastname]     VARCHAR (70)  NOT NULL,
    [Emailaddress] VARCHAR (100) NOT NULL,
    [Codeharshkey] VARCHAR (100) NOT NULL,
    [Employeecode] VARCHAR (100) NOT NULL,
    [Changecode]   BIT           DEFAULT ((1)) NOT NULL,
    [Createdby]    BIGINT        NOT NULL,
    [Modifiedby]   BIGINT        NOT NULL,
    [Datecreated]  DATETIME      NOT NULL,
    [Datemodofied] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([EmployeeId] ASC)
);

