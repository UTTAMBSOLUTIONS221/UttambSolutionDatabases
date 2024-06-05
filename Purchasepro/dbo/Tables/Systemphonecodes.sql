CREATE TABLE [dbo].[Systemphonecodes] (
    [Phoneid]  BIGINT       IDENTITY (1, 1) NOT NULL,
    [Codename] VARCHAR (20) NOT NULL,
    PRIMARY KEY CLUSTERED ([Phoneid] ASC),
    UNIQUE NONCLUSTERED ([Codename] ASC),
    UNIQUE NONCLUSTERED ([Codename] ASC)
);

