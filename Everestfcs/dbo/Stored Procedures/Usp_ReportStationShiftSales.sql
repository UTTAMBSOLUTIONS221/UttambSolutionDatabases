CREATE PROCEDURE [dbo].[Usp_ReportStationShiftSales] 
    @JsonObjectdata VARCHAR(MAX),
    @StationShiftDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
    SELECT @StationShiftDetailsJson =	
	        (SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
            (SELECT SST.Sname AS StationName,SS.ShiftCode,SS.ShiftCategory,SS.CashOrAccount,SS.ShiftDateTime,CASE WHEN SS.ShiftStatus=0 THEN 'Open' WHEN  SS.ShiftStatus=1  THEN 'Closed' END AS ShiftStatus,SS.IsPosted,SS.IsDeleted,SS.ShiftBalance,SS.ShiftReference,SS.Createdby,SS.Modifiedby,SS.Datemodified,SS.Datecreated
			 FROM Stationshifts SS
			 INNER JOIN SystemStations SST ON SS.StationId=SST.StationId
			 WHERE SS.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AND (SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift') OR 0=JSON_VALUE(@JsonObjectdata, '$.Shift'))
			 AND (SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station') OR 0=JSON_VALUE(@JsonObjectdata, '$.Station'))
			 FOR JSON PATH
			) AS StationShiftDetails
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );
END