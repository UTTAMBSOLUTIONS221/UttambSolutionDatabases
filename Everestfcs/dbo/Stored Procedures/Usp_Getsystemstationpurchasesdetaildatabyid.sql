CREATE PROCEDURE [dbo].[Usp_Getsystemstationpurchasesdetaildatabyid]
    @PurchaseId BIGINT,
	@SystemStationPurchasesDetailData VARCHAR(MAX)  OUTPUT
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
		     SET @SystemStationPurchasesDetailData = (
			    SELECT SP.PurchaseId,SP.StationId,SP.InvoiceNumber,SP.SupplierId,SP.InvoiceAmount,SP.InvoiceDate,SP.TruckNumber,SP.DriverName,SP.Extra,SP.Extra1,SP.Extra2,SP.Extra3,
				SP.Extra4,SP.Extra5,SP.Extra6,SP.Extra7,SP.Extra8,SP.Extra9,SP.Extra10,SP.Createdby,SP.Modifiedby,SP.Datemodified,SP.Datecreated,
				(SELECT SPI.PurchaseItemId,SPI.PurchaseId,SPI.ProductVariationId,SPI.PurchaseQuantity,SPI.PurchasePrice,SPI.PurchaseDiscount,SPI.PurchaseTotal,SPI.Extra,SPI.Extra1,
				 SPI.Extra2,SPI.Extra3,SPI.Extra4,SPI.Extra5,SPI.Extra6,SPI.Extra7,SPI.Extra8,SPI.Extra9,SPI.Extra10,SPI.Createdby,SPI.Modifiedby,SPI.Datemodified,SPI.Datecreated
				 FROM StationPurchaseItems SPI
				 WHERE SP.PurchaseId=SPI.PurchaseId
				 FOR JSON PATH
				) AS StationPurchaseItem
				FROM StationPurchases SP WHERE SP.PurchaseId=@PurchaseId
				FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
			  )
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
           SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@SystemStationPurchasesDetailData AS SystemStationPurchasesDetailData  
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