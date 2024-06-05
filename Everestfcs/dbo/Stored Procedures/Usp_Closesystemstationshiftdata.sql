CREATE PROCEDURE [dbo].[Usp_Closesystemstationshiftdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@ShiftId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate
		IF (
				(SELECT SUM(STRR.QuantitySold)
				 FROM ShiftsTankReadings STRR
				 INNER JOIN StationTanks SST ON STRR.TankId = SST.TankId
				 INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
				 WHERE STRR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.ShiftId')
				) - 
				(SELECT SUM(SPR.ElectronicSold)
				 FROM ShiftsPumpReadings SPR
				 INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
				 INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
				 INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
				 WHERE SPR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.ShiftId')
				) > 5
			)
			BEGIN
				Select 1 as RespStatus, 'The liters difference its beyond threshhold' as RespMessage
				return;
			END
		BEGIN TRANSACTION;
	     UPDATE Stationshifts SET ShiftStatus=1,ShiftReference=JSON_VALUE(@JsonObjectdata, '$.ShiftReference'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2) WHERE ShiftId=JSON_VALUE(@JsonObjectdata, '$.ShiftId')
		 SET @ShiftId = JSON_VALUE(@JsonObjectdata, '$.ShiftId');
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage;

		END TRY
		BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ''
		PRINT 'Error ' + error_message();
		Select 2 as RespStatus, '0 - Error(s) Occurred' + error_message() as RespMessage
		END CATCH
		Select @RespStat as RespStatus, @RespMsg as RespMessage;
		RETURN; 
		END;
	END
END