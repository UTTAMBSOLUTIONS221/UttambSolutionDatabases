CREATE PROCEDURE [dbo].[Usp_ResetuserpasswordpostData]
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
		UPDATE Systemstaffs SET Passwords= JSON_VALUE(@JsonObjectdata, '$.Passwords'),Passharsh = JSON_VALUE(@JsonObjectdata, '$.Passwordhash'),Loginstatus=0 WHERE Userid=JSON_VALUE(@JsonObjectdata, '$.Userid')

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
