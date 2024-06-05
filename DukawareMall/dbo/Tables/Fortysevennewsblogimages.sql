CREATE TABLE [dbo].[Fortysevennewsblogimages] (
    [Systemblogimageid]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [Systemblogid]       BIGINT        NOT NULL,
    [Systemblogimageurl] VARCHAR (400) NOT NULL,
    PRIMARY KEY CLUSTERED ([Systemblogimageid] ASC)
);

