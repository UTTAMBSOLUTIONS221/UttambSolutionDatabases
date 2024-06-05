CREATE TABLE [dbo].[Fortysevennewsblogparagraphs] (
    [Systemblogparagraphid] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Systemblogid]          BIGINT         NOT NULL,
    [Systemblogparagraph]   VARCHAR (8000) NOT NULL,
    PRIMARY KEY CLUSTERED ([Systemblogparagraphid] ASC)
);

