CREATE TABLE [dbo].[ShiftPayment] (
    [ShiftPaymentId]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [ShiftId]          BIGINT          NOT NULL,
    [AttendantId]      BIGINT          NOT NULL,
    [CustomerId]       BIGINT          NOT NULL,
    [PaymentModeId]    BIGINT          NOT NULL,
    [PaymentAmount]    DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [PaymentReference] VARCHAR (200)   NULL,
    [IsReversed]       BIT             DEFAULT ((0)) NOT NULL,
    [Createdby]        BIGINT          NOT NULL,
    [Modifiedby]       BIGINT          NOT NULL,
    [DateCreated]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [DateModified]     DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ShiftPaymentId] ASC),
    FOREIGN KEY ([ShiftId]) REFERENCES [dbo].[Stationshifts] ([ShiftId])
);

