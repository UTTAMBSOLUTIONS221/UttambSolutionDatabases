CREATE PROCEDURE [dbo].[Usp_Supervisorclosesystemstationshiftdata]
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