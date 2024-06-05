CREATE TABLE [dbo].[Socialpesaadverts] (
    [AdvertId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [Advertlink]  VARCHAR (400) NOT NULL,
    [Isvideo]     BIT           NOT NULL,
    [Isactive]    BIT           DEFAULT ((0)) NOT NULL,
    [Isdeleted]   BIT           DEFAULT ((0)) NOT NULL,
    [Enddate]     DATETIME      NOT NULL,
    [Datecreated] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([AdvertId] ASC)
);

