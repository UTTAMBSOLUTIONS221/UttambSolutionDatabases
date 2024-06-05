CREATE PROCEDURE [dbo].[Usp_Getsystemstationtankshiftpurchasedata]
	@ShiftId BIGINT,
	@TankId BIGINT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		
		BEGIN TRANSACTION;
	       SELECT  SPI.PurchaseQuantity FROM ShiftPurchasesItems SPI INNER JOIN ShiftPurchases SP ON SPI.PurchaseId=SP.PurchaseId WHERE SP.ShiftId=@ShiftId AND SPI.TankId=@TankId

	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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