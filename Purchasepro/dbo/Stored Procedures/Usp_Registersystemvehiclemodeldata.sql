CREATE PROCEDURE [dbo].[Usp_Registersystemvehiclemodeldata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.Vehiclemodelid')=0)
			BEGIN
				INSERT INTO Systemvehiclemodels(Vehiclemakeid,Vehiclemodelname)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Vehiclemakeid'),JSON_VALUE(@JsonObjectdata, '$.Vehiclemodelname'))
				Set @RespMsg ='Saved Successfully.'
				Set @RespStat =0; 
			END
		ELSE
			BEGIN
				UPDATE Systemvehiclemodels SET Vehiclemakeid=JSON_VALUE(@JsonObjectdata, '$.Vehiclemakeid'),Vehiclemodelname=JSON_VALUE(@JsonObjectdata, '$.Vehiclemodelname') WHERE Vehiclemodelid=JSON_VALUE(@JsonObjectdata, '$.Vehiclemodelid')
				Set @RespMsg ='Updated Successfully.'
				Set @RespStat =0; 
			END
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