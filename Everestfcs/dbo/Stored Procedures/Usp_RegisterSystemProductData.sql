CREATE PROCEDURE [dbo].[Usp_RegisterSystemProductData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@PriceListId BIGINT,
			@ProductId BIGINT,
			@ProductvariationId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;

		  INSERT INTO SystemProduct(TenantId,CategoryId,UomId,Productname,Productdescription,Createdby,Modifiedby,DateCreated,DateModified)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'), JSON_VALUE(@JsonObjectdata, '$.CategoryId'),JSON_VALUE(@JsonObjectdata, '$.UomId'),JSON_VALUE(@JsonObjectdata, '$.Productname'),JSON_VALUE(@JsonObjectdata, '$.Productname'),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))

		SET @ProductId = SCOPE_IDENTITY();
		 
		INSERT INTO SystemProductvariation(Productvariationname,ProductId,TaxId,Barcode,TaxclassificationCode,Levyamount,Levyreference,Referencenumber,Imageurl,Isactive,Isdeleted,Createdby,Modifiedby,DateCreated,DateModified)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Productname'),@ProductId, 0,JSON_VALUE(@JsonObjectdata, '$.Barcode'),0,0,'No Set','Not Set','Not Set',1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))
		
		SET @ProductvariationId = SCOPE_IDENTITY();

		IF NOT EXISTS(SELECT PriceListId FROM PriceList WHERE IsDefault=1 AND TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))
		BEGIN
			INSERT INTO PriceList(TenantId,PriceListname,IsDefault,CreatedBy,ModifiedBy,DateCreated,DateModified)
			(SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'), 'Default Price',1,
			JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
			CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))

		  SET @PriceListId = SCOPE_IDENTITY();

		    INSERT INTO PriceListprices(PriceListId,ProductvariationId,ProductPrice,ProductVat,StationId)
			SELECT @PriceListId, @ProductvariationId,JSON_VALUE(@JsonObjectdata, '$.Productprice'),JSON_VALUE(@JsonObjectdata, '$.ProductVat'),StationId
			FROM OPENJSON (@JsonObjectdata, '$.ProductPriceStations')
			WITH (StationId BIGINT)
		END
		ELSE
		BEGIN
		    SET @PriceListId =(SELECT PriceListId FROM PriceList WHERE IsDefault=1)
			INSERT INTO PriceListprices(PriceListId,ProductvariationId,ProductPrice,ProductVat,StationId)
			SELECT @PriceListId, @ProductvariationId,JSON_VALUE(@JsonObjectdata, '$.Productprice'),JSON_VALUE(@JsonObjectdata, '$.ProductVat'),StationId
			FROM OPENJSON (@JsonObjectdata, '$.ProductPriceStations')
			WITH (StationId BIGINT)
		END
		
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
