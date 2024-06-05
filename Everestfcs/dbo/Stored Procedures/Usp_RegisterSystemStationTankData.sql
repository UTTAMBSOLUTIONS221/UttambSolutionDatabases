CREATE PROCEDURE [dbo].[Usp_RegisterSystemStationTankData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.TankId')=0)
		BEGIN
		 INSERT INTO Stationtanks(Stationid,Productvariationid,Name,Description,Length,Diameter,Volume,NumberOfCalibrations,IsActive,IsDeleted,CreatedBy,ModifiedBy,DateCreated,DateModified)
		  SELECT JSON_VALUE(@JsonObjectdata, '$.StationId'),JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),JSON_VALUE(@JsonObjectdata, '$.Name'),JSON_VALUE(@JsonObjectdata, '$.Description'),JSON_VALUE(@JsonObjectdata, '$.Length'),JSON_VALUE(@JsonObjectdata, '$.Diameter'),JSON_VALUE(@JsonObjectdata, '$.Volume'),JSON_VALUE(@JsonObjectdata, '$.NumberOfCalibrations'),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated')  AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
	
		 END
		ELSE
		BEGIN
		  UPDATE Stationtanks SET Productvariationid=JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),Name=JSON_VALUE(@JsonObjectdata, '$.Name'),Volume=JSON_VALUE(@JsonObjectdata, '$.Volume'),Diameter=JSON_VALUE(@JsonObjectdata, '$.Diameter'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE Tankid=JSON_VALUE(@JsonObjectdata, '$.TankId')
		
		 END
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
