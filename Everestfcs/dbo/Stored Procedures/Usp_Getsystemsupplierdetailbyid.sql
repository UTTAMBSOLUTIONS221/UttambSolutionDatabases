CREATE PROCEDURE [dbo].[Usp_Getsystemsupplierdetailbyid]
	@SupplierId BIGINT,
	@SystemSupplierData  NVARCHAR(MAX) OUTPUT
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
		IF(@SupplierId!=0)
		BEGIN
	    SET @SystemSupplierData =(SELECT a.SupplierId,a.TenantId,a.SupplierName,a.SupplierEmail,a.PhoneId,a.PhoneNumber,a.Extra,a.Extra1,a.Extra2,a.Extra3,
		a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Createdby,a.Modifiedby,a.Datemodified,a.Datecreated,
		(SELECT SP.SupplierPriceId,SP.SupplierId,SP.ProductVariationId,SPV.ProductVariationName,PC.Categoryname,SP.ProductPrice,SP.ProductVat,SP.Createdby,SP.Modifiedby,SP.DateCreated,SP.DateModified
		 FROM SystemSuplierPrice SP
		 INNER JOIN SystemProductvariation SPV ON SP.ProductVariationId=SPV.ProductVariationId
		 INNER JOIN SystemProduct t ON SPV.ProductId=t.ProductId 
		 INNER JOIN Productcategory PC ON t.CategoryId=PC.CategoryId
		 WHERE   (@SupplierId = 0 OR SP.SupplierId = @SupplierId)
		 FOR JSON PATH
		 ) AS SystemSuplierPrice 
		FROM SystemSuppliers a WHERE SupplierId=@SupplierId
		 FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		 );
		 END
		 ELSE
		 BEGIN
		 SET @SystemSupplierData =(SELECT 0 AS SupplierId,0 AS TenantId,0 AS SupplierName,0 AS SupplierEmail,0 AS PhoneId,0 AS PhoneNumber,0 AS Createdby,0 AS Modifiedby, GETDATE() AS Datemodified, GETDATE() AS Datecreated,
		(SELECT 0 AS SupplierPriceId, 0 AS SupplierId,r.ProductVariationId,r.ProductVariationName,PC.Categoryname, 0 AS ProductPrice, 0 AS ProductVat, 0 AS  Createdby, 0 AS Modifiedby, GETDATE() AS DateCreated, GETDATE() AS DateModified
		 FROM SystemProductvariation r 
		 INNER JOIN SystemProduct t ON r.ProductId=t.ProductId 
		 INNER JOIN Productcategory PC ON t.CategoryId=PC.CategoryId
		 FOR JSON PATH
		 ) AS SystemSuplierPrice 
		FROM SystemSuppliers a
		 FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		 );
		 END
		Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@SystemSupplierData AS SystemSupplierData

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