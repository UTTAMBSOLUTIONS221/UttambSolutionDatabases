CREATE TABLE [dbo].[SocialPesaFacebookPages] (
    [PageId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [Pagename]     VARCHAR (70)  NOT NULL,
    [Page_id]      VARCHAR (70)  NOT NULL,
    [Access_token] VARCHAR (200) NOT NULL,
    PRIMARY KEY CLUSTERED ([PageId] ASC)
);

