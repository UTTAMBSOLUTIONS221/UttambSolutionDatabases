CREATE PROCEDURE [dbo].[Usp_Getsystemcreditinvoicesaledatabyid]
	@ShiftCreditInvoiceId BIGINT
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
		SELECT ShiftCreditInvoiceId,ShiftId,AttendantId,CustomerId,EquipmentId,ProductVariationId,ProductUnits,ProductPrice,ProductDiscount,ProductTotal,
        Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated
        FROM ShiftCreditInvoices WHERE ShiftCreditInvoiceId=@ShiftCreditInvoiceId

		Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage;

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