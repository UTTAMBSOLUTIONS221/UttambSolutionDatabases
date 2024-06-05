CREATE TABLE [dbo].[ReplacedCards] (
    [ReplacedCardid] BIGINT   IDENTITY (1, 1) NOT NULL,
    [OldCardid]      BIGINT   NOT NULL,
    [NewCardid]      BIGINT   NOT NULL,
    [Replacedby]     BIGINT   NOT NULL,
    [Datecreated]    DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([ReplacedCardid] ASC)
);

