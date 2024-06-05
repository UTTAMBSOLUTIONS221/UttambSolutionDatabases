CREATE PROCEDURE [dbo].[Usp_Resetuserpasswordpostdata]
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
		UPDATE systemstaffs SET Passwords= JSON_VALUE(@JsonObjectdata, '$.Passwords'),Passwordharsh = JSON_VALUE(@JsonObjectdata, '$.Passwordhash'),Loginstatus=0,Changepassword=0,Passwordchangedate= GETDATE() WHERE StaffId=JSON_VALUE(@JsonObjectdata, '$.Staffid')

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