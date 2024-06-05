CREATE PROCEDURE [dbo].[Usp_RegisterSystemStationPumpData]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.PumpId')=0)
		BEGIN
		 INSERT INTO Stationpumps(Stationid,Tankid,Pumpname,Pumpmodel,Description,Code,IsDoubleSided,IsActive,IsDeleted,CreatedBy,ModifiedBy,DateCreated,DateModified)
		  SELECT JSON_VALUE(@JsonObjectdata, '$.Stationid'),JSON_VALUE(@JsonObjectdata, '$.Tankid'),JSON_VALUE(@JsonObjectdata, '$.Pumpname'),JSON_VALUE(@JsonObjectdata, '$.Pumpmodel'),JSON_VALUE(@JsonObjectdata, '$.Description'),JSON_VALUE(@JsonObjectdata, '$.Code'),JSON_VALUE(@JsonObjectdata, '$.IsDoubleSided'),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated')  AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
		 END
		ELSE
		BEGIN
		  UPDATE Stationpumps SET Tankid=JSON_VALUE(@JsonObjectdata, '$.Tankid'),Pumpname=JSON_VALUE(@JsonObjectdata, '$.Pumpname'),Pumpmodel=JSON_VALUE(@JsonObjectdata, '$.Pumpmodel'),Description=JSON_VALUE(@JsonObjectdata, '$.Description'),Code=JSON_VALUE(@JsonObjectdata, '$.Code'),IsDoubleSided=JSON_VALUE(@JsonObjectdata, '$.IsDoubleSided'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE Pumpid=JSON_VALUE(@JsonObjectdata, '$.Pumpid')
		
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