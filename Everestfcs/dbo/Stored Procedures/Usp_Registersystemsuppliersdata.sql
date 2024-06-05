CREATE PROCEDURE [dbo].[Usp_Registersystemsuppliersdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@SupplierId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		DECLARE @SystemSuppliers TABLE (SupplierId BIGINT)
		-- Merge for the purchase
		MERGE INTO SystemSuppliers AS target
		USING (SELECT JSON_VALUE(@JsonObjectdata, '$.SupplierId') AS SupplierId,JSON_VALUE(@JsonObjectdata, '$.TenantId') AS TenantId,JSON_VALUE(@JsonObjectdata, '$.SupplierName') AS SupplierName,JSON_VALUE(@JsonObjectdata, '$.SupplierEmail') AS SupplierEmail,JSON_VALUE(@JsonObjectdata, '$.PhoneId') AS PhoneId,JSON_VALUE(@JsonObjectdata, '$.PhoneNumber') AS PhoneNumber,JSON_VALUE(@JsonObjectdata, '$.Extra') AS Extra,JSON_VALUE(@JsonObjectdata, '$.Extra1') AS Extra1,JSON_VALUE(@JsonObjectdata, '$.Extra2') AS Extra2,JSON_VALUE(@JsonObjectdata, '$.Extra3') AS Extra3,JSON_VALUE(@JsonObjectdata, '$.Extra4') AS Extra4,JSON_VALUE(@JsonObjectdata, '$.Extra5') AS Extra5,JSON_VALUE(@JsonObjectdata, '$.Extra6') AS Extra6,JSON_VALUE(@JsonObjectdata, '$.Extra7') AS Extra7,JSON_VALUE(@JsonObjectdata, '$.Extra8') AS Extra8,JSON_VALUE(@JsonObjectdata, '$.Extra9') AS Extra9,JSON_VALUE(@JsonObjectdata, '$.Extra10') AS Extra10,JSON_VALUE(@JsonObjectdata, '$.Createdby') AS Createdby,JSON_VALUE(@JsonObjectdata, '$.Modifiedby') AS Modifiedby,TRY_PARSE(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS DATETIME) AS Datemodified,TRY_PARSE(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS DATETIME) AS DateCreated
		) AS source ON target.SupplierId = source.SupplierId 
		WHEN MATCHED THEN UPDATE SET target.TenantId = source.TenantId,target.SupplierName = source.SupplierName,target.SupplierEmail = source.SupplierEmail,target.PhoneId = source.PhoneId,target.PhoneNumber = source.PhoneNumber,target.Extra = source.Extra,target.Extra1 = source.Extra1,target.Extra2 = source.Extra2,target.Extra3 = source.Extra3,target.Extra4 = source.Extra4,target.Extra5 = source.Extra5,target.Extra6 = source.Extra6,target.Extra7 = source.Extra7,target.Extra8 = source.Extra8,target.Extra9 = source.Extra9,target.Extra10 = source.Extra10,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
		WHEN NOT MATCHED THEN INSERT (TenantId,SupplierName,SupplierEmail,PhoneId,PhoneNumber,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated)
		VALUES (source.TenantId,source.SupplierName,source.SupplierEmail,source.PhoneId,source.PhoneNumber,source.Extra,source.Extra1,source.Extra2,source.Extra3,source.Extra4,source.Extra5,source.Extra6,source.Extra7,source.Extra8,source.Extra9,source.Extra10,source.Createdby,source.Modifiedby,source.DateModified,source.DateCreated)
		OUTPUT inserted.SupplierId INTO @SystemSuppliers;
		SET @SupplierId = (SELECT SupplierId FROM @SystemSuppliers);

		-- Merge for the purchase items
		MERGE INTO SystemSuplierPrice AS target
		USING (SELECT JSON_VALUE(items.value, '$.SupplierPriceId') AS SupplierPriceId,JSON_VALUE(items.value, '$.ProductVariationId') AS ProductVariationId,JSON_VALUE(items.value, '$.ProductPrice') AS ProductPrice,JSON_VALUE(items.value, '$.ProductVat') AS ProductVat,JSON_VALUE(items.value, '$.Createdby') AS Createdby,JSON_VALUE(items.value, '$.Modifiedby') AS Modifiedby,TRY_PARSE(JSON_VALUE(items.value, '$.DateModified') AS DATETIME) AS DateModified,TRY_PARSE(JSON_VALUE(items.value, '$.DateCreated') AS DATETIME) AS DateCreated
		FROM OPENJSON(@JsonObjectdata, '$.SystemSuplierPrice') AS items
		) AS source ON target.SupplierPriceId = source.SupplierPriceId -- Assuming ItemId is the unique identifier
		WHEN MATCHED THEN 
		UPDATE SET target.ProductVariationId = source.ProductVariationId,target.ProductPrice = source.ProductPrice,target.ProductVat = source.ProductVat,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
		WHEN NOT MATCHED THEN
		INSERT (SupplierId,ProductVariationId,ProductPrice,ProductVat,Createdby,Modifiedby,DateCreated,DateModified)
		VALUES (@SupplierId,source.ProductVariationId,source.ProductPrice,source.ProductVat,source.Createdby,source.Modifiedby,source.Datecreated,source.Datemodified);

		Set @RespMsg ='Success'
		Set @RespStat =0; 
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