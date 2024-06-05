CREATE PROCEDURE [dbo].[Usp_ValidateSystemCustomer]
	@RequestId BIGINT,
	@EncryptedPin VARCHAR(200)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'OK',
			@CustomerId BIGINT;
			
			BEGIN
		BEGIN TRY
		--validate	
		IF NOT EXISTS(SELECT a.CustomerId FROM Customers a WHERE a.CustomerId=@RequestId AND a.Pin=@EncryptedPin)
		BEGIN
		Select  1 as RespStatus, 'Customer pin is invalid. Kindly try again!' as RespMessage;
		return;
		END
		BEGIN TRANSACTION;
	      SELECT @CustomerId=a.CustomerId FROM Customers a WHERE a.CustomerId=@RequestId AND a.Pin=@EncryptedPin


	    Set @RespMsg ='OK.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerId AS Data1;

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
