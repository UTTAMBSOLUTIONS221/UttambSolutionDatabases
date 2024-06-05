CREATE PROCEDURE [dbo].[Usp_GetSystemStatonStatementDetailData]
    @StartDate DATE,
    @EndDate DATE,
    @StationId INT,
	@ShiftId BIGINT,
    @StationSaleStatementData NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Json NVARCHAR(MAX);

    WITH ShiftsData AS (
        SELECT 
            AA.ShiftId,
            AA.AttendantId,
            BB.StationId,
            BB.ShiftCode,
            BB.ShiftCategory,
            BB.CashOrAccount,
            BB.ShiftDateTime,
            BB.ShiftStatus,
            BB.ShiftBalance,
            AA.Createdby,
            AA.Modifiedby,
            AA.Datemodified,
            AA.Datecreated,
            SUM(AA.OpeningRead) AS TotalOpeningRead,
            SUM(AA.ClosingRead) AS TotalClosingRead
        FROM StationshiftsData AA 
        INNER JOIN Stationshifts BB ON AA.ShiftId = BB.ShiftId 
        WHERE BB.ShiftDateTime BETWEEN @StartDate AND @EndDate
        AND BB.StationId = @StationId
        GROUP BY 
            AA.ShiftId,
            AA.AttendantId,
            BB.StationId,
            BB.ShiftCode,
            BB.ShiftCategory,
            BB.CashOrAccount,
            BB.ShiftDateTime,
            BB.ShiftStatus,
            BB.ShiftBalance,
            AA.Createdby,
            AA.Modifiedby,
            AA.Datemodified,
            AA.Datecreated
    ),
    SalesData AS (
        SELECT 
            AA.ShiftId,
            AA.AttendantId,
            BB.StationId,
            BB.ShiftCode,
            BB.ShiftCategory,
            BB.CashOrAccount,
            BB.ShiftDateTime,
            BB.ShiftStatus,
            BB.ShiftBalance,
            AA.Createdby,
            AA.Modifiedby,
            AA.Datemodified,
            AA.Datecreated,
            SUM(AA.ClosingRead - AA.OpeningRead) AS Sales
        FROM StationshiftsData AA 
        INNER JOIN Stationshifts BB ON AA.ShiftId = BB.ShiftId 
        WHERE BB.ShiftDateTime BETWEEN @StartDate AND @EndDate
        AND BB.StationId = @StationId
        GROUP BY 
            AA.ShiftId,
            AA.AttendantId,
            BB.StationId,
            BB.ShiftCode,
            BB.ShiftCategory,
            BB.CashOrAccount,
            BB.ShiftDateTime,
            BB.ShiftStatus,
            BB.ShiftBalance,
            AA.Createdby,
            AA.Modifiedby,
            AA.Datemodified,
            AA.Datecreated
    )
    
    SELECT 
        @Json = (
            SELECT 
                'Default Station' AS StationName,
                @StartDate AS StartDate,
                @EndDate AS EndDate,
                (
                    SELECT 
                        A.ShiftCode,
                        A.ShiftCategory,
                        A.ShiftDateTime,
                        CASE WHEN A.ShiftStatus= 0 THEN 'Open' WHEN A.ShiftStatus= 1 THEN 'Closed' ELSE 'Voided' END AS ShiftStatus,
						CASE WHEN S.Sales<0 THEN 'Loss' ELSE 'Gain' END AS ShiftStatusGain, 0 AS  PercentShiftStatusGain,
                        SS.Firstname + ' ' + SS.Lastname AS Attendant,
                        COALESCE(B.TotalOpeningRead, 0) AS TotalOpeningRead,
                        COALESCE(C.TotalClosingRead, 0) AS TotalClosingRead,
                        COALESCE(S.Sales, 0) AS TotalSales
                    FROM Stationshifts A 
                    LEFT JOIN ShiftsData B ON A.ShiftId = B.ShiftId
                    LEFT JOIN ShiftsData C ON A.ShiftId = C.ShiftId + 1
                    LEFT JOIN SalesData S ON A.ShiftId = S.ShiftId
                    INNER JOIN SystemStaffs SS ON B.AttendantId = SS.Userid
                    FOR JSON PATH
                ) AS Stationshiftstatements
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    SET @StationSaleStatementData = @Json;
END