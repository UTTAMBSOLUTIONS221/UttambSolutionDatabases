CREATE TABLE [dbo].[Systemmodules] (
    [ModuleId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [Modulename]  VARCHAR (50)  NOT NULL,
    [Moduleemail] VARCHAR (100) NOT NULL,
    [PhoneId]     BIGINT        NOT NULL,
    [Modulephone] VARCHAR (12)  NOT NULL,
    [Modulelogo]  VARCHAR (400) DEFAULT ('https://www.lenarjisse.com/images/no-image.png') NOT NULL,
    PRIMARY KEY CLUSTERED ([ModuleId] ASC)
);

