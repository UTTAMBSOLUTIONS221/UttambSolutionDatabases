CREATE PROCEDURE [dbo].[Usp_ValidateSystemCustomeremployee]
	@RequestId BIGINT,
	@EncryptedPin VARCHAR(200)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'OK',
			@EmployeeId BIGINT;
			
			BEGIN
		BEGIN TRY
		--validate	
		IF NOT EXISTS(SELECT b.EmployeeId FROM AccountEmployee a INNER JOIN CustomerEmployees b ON a.EmployeeId=b.EmployeeId WHERE a.AccountId=@RequestId AND b.Employeecode=@EncryptedPin)
		BEGIN
		Select  1 as RespStatus, 'Customer pin is invalid. Kindly try again!' as RespMessage;
		return;
		END
		BEGIN TRANSACTION;
	      SELECT @EmployeeId=b.EmployeeId FROM AccountEmployee a INNER JOIN CustomerEmployees b ON a.EmployeeId=b.EmployeeId WHERE a.AccountId=@RequestId AND b.Employeecode=@EncryptedPin


	    Set @RespMsg ='OK.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@EmployeeId AS Data1;

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
