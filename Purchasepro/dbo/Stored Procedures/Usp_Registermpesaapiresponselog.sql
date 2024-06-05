CREATE PROCEDURE [dbo].[Usp_Registermpesaapiresponselog]
    @IsTxnSuccessFull BIT,
	@Action VARCHAR(100),
	@StatusCode INT,
	@Response VARCHAR(200),
	@DateCreated DATETIME
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
		BEGIN
				INSERT INTO Mpesaapiresponselogs(IsTxnSuccessFull,Action,StatusCode,Response,DateCreated)
				VALUES(@IsTxnSuccessFull,@Action,@StatusCode,@Response,@DateCreated)
				Set @RespMsg ='Log Saved Successfully.'
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