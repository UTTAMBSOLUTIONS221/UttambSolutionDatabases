CREATE TABLE [dbo].[LnkGadgetsStation] (
    [GadgetId]  BIGINT NOT NULL,
    [StationId] BIGINT NOT NULL,
    FOREIGN KEY ([GadgetId]) REFERENCES [dbo].[SystemGadgets] ([GadgetId]),
    FOREIGN KEY ([StationId]) REFERENCES [dbo].[SystemStations] ([StationId])
);

