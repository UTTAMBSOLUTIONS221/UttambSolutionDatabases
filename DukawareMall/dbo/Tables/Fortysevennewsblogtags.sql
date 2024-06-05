CREATE TABLE [dbo].[Fortysevennewsblogtags] (
    [Systemblogtagid] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Systemblogid]    BIGINT        NOT NULL,
    [Systemblogtag]   VARCHAR (400) NOT NULL,
    PRIMARY KEY CLUSTERED ([Systemblogtagid] ASC)
);

