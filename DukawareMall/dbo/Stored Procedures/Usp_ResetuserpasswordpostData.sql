CREATE PROCEDURE [dbo].[Usp_ResetuserpasswordpostData]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = '';

			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		BEGIN
		UPDATE Systemstaffs  SET Passwords=JSON_VALUE(@JsonObjectdata, '$.Passwords'),passwordharsh=JSON_VALUE(@JsonObjectdata, '$.Passwordhash'),Changepassword=0,LoginStatus=1 WHERE StaffId =JSON_VALUE(@JsonObjectdata, '$.Userid')

		Set @RespMsg ='Password Changed.'
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