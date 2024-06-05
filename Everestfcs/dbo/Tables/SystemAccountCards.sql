CREATE TABLE [dbo].[SystemAccountCards] (
    [AccountId] BIGINT NOT NULL,
    [CardId]    BIGINT NOT NULL,
    FOREIGN KEY ([CardId]) REFERENCES [dbo].[Systemcard] ([CardId]),
    FOREIGN KEY ([CardId]) REFERENCES [dbo].[Systemcard] ([CardId])
);

