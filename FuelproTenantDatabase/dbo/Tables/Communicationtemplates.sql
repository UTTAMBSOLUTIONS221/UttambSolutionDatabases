CREATE TABLE [dbo].[Communicationtemplates] (
    [Templateid]      BIGINT        IDENTITY (1, 1) NOT NULL,
    [Templatename]    VARCHAR (100) NOT NULL,
    [Templatesubject] VARCHAR (100) NOT NULL,
    [Templatebody]    VARCHAR (MAX) NOT NULL,
    [Isactive]        BIT           DEFAULT ((1)) NOT NULL,
    [Isdeleted]       BIT           DEFAULT ((0)) NOT NULL,
    [Isemailsms]      BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([Templateid] ASC),
    UNIQUE NONCLUSTERED ([Templatename] ASC)
);

