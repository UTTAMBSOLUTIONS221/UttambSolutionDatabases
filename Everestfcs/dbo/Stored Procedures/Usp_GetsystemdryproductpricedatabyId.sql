CREATE PROCEDURE [dbo].[Usp_GetsystemdryproductpricedatabyId]
	@ProductVariationId BIGINT,
	@StationId BIGINT,
	@CustomerId BIGINT
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
		IF(@CustomerId=0)
		BEGIN
			SELECT a.ProductvariationId,b.Productvariationname,a.ProductPrice,0 AS DiscountValue,a.ProductVat AS VatValue
			FROM  PriceListprices a 
			INNER JOIN SystemProductvariation b ON a.ProductVariationId=b.ProductVariationId 
			INNER JOIN SystemProduct c ON b.ProductId=c.ProductId  WHERE a.ProductvariationId=@ProductVariationId AND StationId=@StationId
		END
		ELSE
		BEGIN
		    SELECT D.ProductvariationId,b.Productvariationname,D.ProductPrice,E.DiscountValue,D.ProductVat AS VatValue
			FROM  CustomerAgreements a
			INNER JOIN PriceListprices D ON a.PriceListId=D.PriceListId
			INNER JOIN LnkDiscountProducts E ON a.DiscountlistId=E.DiscountlistId
			INNER JOIN SystemProductvariation b ON D.ProductVariationId=b.ProductVariationId 
			INNER JOIN SystemProduct c ON b.ProductId=c.ProductId  WHERE D.ProductvariationId=@ProductVariationId AND D.StationId=@StationId AND a.CustomerId =@CustomerId
		END

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