
--EXEC Usp_GetCustomerAccountDetailData @AccountId=8,@CustomerAccountDetailsJson=''

CREATE PROCEDURE [dbo].[Usp_GetSystemProductVariationDetailData]
	@ProductVariationId BIGINT,
	@ProductDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY

		BEGIN TRANSACTION;
		SET @ProductDetailsJson= (
		SELECT b.ProductvariationId,a.ProductId,a.CategoryId,a.UomId ,a.Productname,a.Productdescription,b.Productvariationname,
		b.TaxId,b.Barcode,b.TaxclassificationCode ,b.Levyamount,(SELECT  TOP 1 ProductPrice FROM PriceListprices WHERE ProductvariationId=b.ProductvariationId) AS Productprice,b.Levyreference,b.Referencenumber,b.Imageurl,a.Createdby AS CreatedbyId,a.Modifiedby AS ModifiedId,a.Datecreated,a.Datemodified,
		(SELECT StationId FROM PriceListprices WHERE ProductvariationId=b.ProductvariationId FOR JSON PATH ) AS ProductPriceStations
		FROM SystemProduct a
		INNER JOIN SystemProductvariation b ON A.ProductId=b.ProductId 
		WHERE b.ProductvariationId=@ProductVariationId
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		);

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT @RespStat AS RespStatus, @RespMsg AS RespMessage, @ProductDetailsJson AS ProductDetailsJson ;
	
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