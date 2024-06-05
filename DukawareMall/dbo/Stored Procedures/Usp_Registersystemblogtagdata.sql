CREATE PROCEDURE [dbo].[Usp_Registersystemblogtagdata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.Systemblogtagid')=0)
		BEGIN
		INSERT INTO Fortysevennewsblogtags(Systemblogid,Systemblogtag)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Systemblogid'),JSON_VALUE(@JsonObjectdata, '$.Systemblogtag'))

		Set @RespMsg ='Blog Tags Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Fortysevennewsblogtags 
		SET Systemblogtag=JSON_VALUE(@JsonObjectdata, '$.Systemblogtag') WHERE Systemblogtagid =JSON_VALUE(@JsonObjectdata, '$.Systemblogtagid')

		Set @RespMsg ='Blog Tags Updated Successfully.'
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