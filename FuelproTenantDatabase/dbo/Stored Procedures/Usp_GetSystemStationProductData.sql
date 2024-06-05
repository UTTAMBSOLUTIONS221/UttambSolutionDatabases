CREATE PROCEDURE [dbo].[Usp_GetSystemStationProductData]
	@StationId BIGINT
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
	  
         SELECT v.ProductvariationId,Productvariationname, CONVERT(numeric(10,2), p.ProductPrice) AS ProductPrice,
		 v.ProductId,Barcode,TaxclassificationCode,Levyamount,Levyreference,PC.Categoryname,UM.Uomname,CASE WHEN  v.ImageUrl='Not Set' THEN 'https://www.lenarjisse.com/images/no-image.png' ELSE  v.ImageUrl END AS Imageurl,
		 Referencenumber,V.Isactive,V.Isdeleted,v.Createdby,v.Modifiedby,v.DateCreated,v.DateModified 
		 FROM SystemProductvariation v
		 INNER JOIN SystemProduct SP ON v.ProductId=SP.ProductId
		 INNER JOIN Productcategory PC ON SP.CategoryId=PC.CategoryId
		 INNER JOIN ProductUoms UM ON SP.UomId=UM.Uomid
		 INNER JOIN PriceListprices p ON v.ProductvariationId=p.ProductvariationId 
		 INNER JOIN PriceList PL ON P.PriceListId=PL.PriceListId
		 WHERE PL.IsDefault=1 AND P.StationId=@StationId 
		 ;
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