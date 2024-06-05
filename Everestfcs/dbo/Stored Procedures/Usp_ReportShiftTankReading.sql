CREATE PROCEDURE [dbo].[Usp_ReportShiftTankReading] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftTankReadingDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
    SELECT @ShiftTankReadingDetailsJson = (
	        SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
            (SELECT STNR.ShiftTankReadingId,STNR.ShiftId,SS.ShiftCode,SS.ShiftDateTime,STNR.TankId,ST.Name AS TankName,STNR.AttendantId,STF.Firstname+' '+STF.Lastname AS AttendantName,STNR.ProductPrice,STNR.OpeningQuantity,(SELECT SUM(SHP.PurchaseQuantity) FROM ShiftPurchasesItems SHP INNER JOIN Stationtanks STP ON SHP.TankId=STP.Tankid INNER JOIN ShiftPurchases SPH ON SHP.PurchaseId=SPH.PurchaseId WHERE STNR.ShiftId=SPH.ShiftId AND SHP.Tankid= ST.Tankid) AS TankPurchase,
			  STNR.ClosingQuantity,STNR.QuantitySold,STNR.AmountSold,(SELECT SUM(SPR.ElectronicSold) FROM ShiftsPumpReadings SPR INNER JOIN Stationpumps SPP ON SPR.PumpId=SPP.Pumpid WHERE STNR.ShiftId=SPR.ShiftId AND SPP.Tankid= ST.Tankid) AS PumpLitres,(SELECT SUM(SPR.ElectronicSold)-STNR.QuantitySold FROM ShiftsPumpReadings SPR INNER JOIN Stationpumps SPP ON SPR.PumpId=SPP.Pumpid WHERE STNR.ShiftId=SPR.ShiftId AND SPP.Tankid= ST.Tankid) AS Differences,(STNR.ProductPrice *(SELECT SUM(SPR.ElectronicSold)-STNR.QuantitySold FROM ShiftsPumpReadings SPR INNER JOIN Stationpumps SPP ON SPR.PumpId=SPP.Pumpid WHERE STNR.ShiftId=SPR.ShiftId AND SPP.Tankid= ST.Tankid)) AS DifferenceValue,STNR.Createdby,CR.Firstname+' '+CR.Lastname AS CreatedByName,STNR.Modifiedby,MR.Firstname+' '+MR.Lastname AS ModifiedByName,STNR.Datemodified,STNR.Datecreated
			  FROM ShiftsTankReadings STNR
			  INNER JOIN Stationtanks ST ON STNR.TankId=ST.TankId
			  INNER JOIN Stationshifts SS ON STNR.ShiftId=SS.ShiftId
			  INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			  INNER JOIN SystemStaffs STF ON STNR.AttendantId=STF.Userid
			  INNER JOIN SystemStaffs CR ON STNR.Createdby=CR.Userid  
			  INNER JOIN SystemStaffs MR ON STNR.Createdby=MR.Userid
			  WHERE STNR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AND (STNR.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift') OR 0=JSON_VALUE(@JsonObjectdata, '$.Shift'))
			  AND (SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station') OR 0=JSON_VALUE(@JsonObjectdata, '$.Station')) AND (STNR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR 0=JSON_VALUE(@JsonObjectdata, '$.Attendant'))
			 FOR JSON PATH
			) AS ShiftTankReading,
			(   
				SELECT SST.Name AS TankName,SUM(STRR.AmountSold) AS TotalTankAmount
				FROM ShiftsTankReadings STRR
				INNER JOIN StationTanks SST ON STRR.TankId = SST.TankId
				 WHERE STRR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AND (STRR.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift') OR 0=JSON_VALUE(@JsonObjectdata, '$.Shift'))
			  AND (SST.StationId=JSON_VALUE(@JsonObjectdata, '$.Station') OR 0=JSON_VALUE(@JsonObjectdata, '$.Station')) AND (STRR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR 0=JSON_VALUE(@JsonObjectdata, '$.Attendant'))
				GROUP BY SST.Name
				FOR JSON PATH
				) AS TankSummary
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );
END