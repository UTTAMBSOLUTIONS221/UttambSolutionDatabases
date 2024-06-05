CREATE PROCEDURE [dbo].[Usp_GetSystemProductVariationData]
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
		  SELECT a.ProductvariationId,a.Productvariationname,c.Categoryname,d.Uomname
		  ,a.Barcode,a.TaxclassificationCode,a.Levyamount,a.Levyreference,a.Referencenumber,a.Imageurl,a.Isactive,a.Isdeleted
		  ,e.Fullname AS Createdby,f.Fullname AS Modifiedby,a.DateCreated,a.DateModified
		  FROM SystemProductvariation a
		  INNER JOIN SystemProduct b ON a.ProductId=b.ProductId
		  INNER JOIN Productcategory c ON b.CategoryId=c.CategoryId
		  INNER JOIN ProductUoms d ON b.UomId =d.UomId
		  INNER JOIN systemStaffs e ON a.Createdby=e.UserId
		  INNER JOIN systemStaffs f ON a.Modifiedby=e.UserId
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