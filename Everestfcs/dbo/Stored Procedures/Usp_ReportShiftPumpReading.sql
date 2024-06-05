CREATE PROCEDURE [dbo].[Usp_ReportShiftPumpReading] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftPumpReadingDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON; -- Added semicolon

    SELECT @ShiftPumpReadingDetailsJson = (
            SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
			(
                SELECT SPR.ShiftPumpReadingId, SPR.ShiftId, SS.ShiftCode, SS.ShiftDateTime, SPR.PumpId, SP.Pumpname, SP.Pumpmodel, SPR.NozzleId, PN.Nozzle, 
                SP.Pumpname+'-'+PN.Nozzle AS WareHouse, SPR.AttendantId, STF.Firstname+' '+STF.Lastname AS AttendantName,
                SPR.ProductPrice, SPR.OpeningShilling, SPR.ClosingShilling, SPR.TotalShilling, SPR.ShillingDifference, SPR.OpeningElectronic, 
                SPR.ClosingElectronic, SPR.ElectronicSold, SPR.ElectronicAmount, SPR.OpeningManual, SPR.ClosingManual, SPR.ManualSold,
                SPR.ManualAmount, SPR.LitersDifference, SPR.TestingRtt, SPR.PumpRttAmount, SPR.TotalPumpAmount, SPR.Createdby, 
                CR.Firstname+' '+CR.Lastname AS CreatedByName, SPR.Modifiedby, MR.Firstname+' '+MR.Lastname AS ModifiedByName,SPR.Datemodified, SPR.Datecreated
                FROM ShiftsPumpReadings SPR
                INNER JOIN Stationpumps SP ON SPR.PumpId=SP.Pumpid
                INNER JOIN PumpNozzles PN ON SPR.NozzleId=PN.NozzleId
                INNER JOIN Stationshifts SS ON SPR.ShiftId=SS.ShiftId
                INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
                INNER JOIN SystemStaffs STF ON SPR.AttendantId=STF.Userid
                INNER JOIN SystemStaffs CR ON SPR.Createdby=CR.Userid  
                INNER JOIN SystemStaffs MR ON SPR.Createdby=MR.Userid
                WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
                AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SS.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SPR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR 0=JSON_VALUE(@JsonObjectdata, '$.Attendant'))
                AND SPR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
                FOR JSON PATH
            ) AS ShiftPumpReading,
			(SELECT SSP.Pumpname ,SUM(SPR.OpeningElectronic) AS OpeningElectronicAmount,SUM(SPR.ClosingElectronic) AS CloseElectronicAmount,SUM(SPR.TotalPumpAmount) AS TotalPumpAmount
			FROM   ShiftsPumpReadings SPR
			INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
			INNER JOIN Stationshifts SS ON SPR.ShiftId=SS.ShiftId
            INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			WHERE  STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SS.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SPR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR 0=JSON_VALUE(@JsonObjectdata, '$.Attendant'))
            AND SPR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY SPR.ShiftId,SSP.Pumpname
			FOR JSON PATH
			) AS PumpSummary
            FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
    );
END