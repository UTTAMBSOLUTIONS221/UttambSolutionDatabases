﻿CREATE PROCEDURE [dbo].[Usp_Registersystemvehiclemakedata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.Vehiclemakeid')=0)
			BEGIN
				INSERT INTO Systemvehiclemakes(Vehiclemakename)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Vehiclemakename'))
				Set @RespMsg ='Saved Successfully.'
				Set @RespStat =0; 
			END
		ELSE
			BEGIN
				UPDATE Systemvehiclemakes SET Vehiclemakename=JSON_VALUE(@JsonObjectdata, '$.Vehiclemakename') WHERE Vehiclemakeid=JSON_VALUE(@JsonObjectdata, '$.Vehiclemakeid')
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