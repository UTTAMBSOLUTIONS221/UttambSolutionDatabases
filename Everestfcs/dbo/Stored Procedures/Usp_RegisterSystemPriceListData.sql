CREATE PROCEDURE [dbo].[Usp_RegisterSystemPriceListData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@PriceListId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		DECLARE @SystemPrices TABLE (PriceListId BIGINT)
		-- Merge for the purchase
		MERGE INTO PriceList AS target
		USING (SELECT JSON_VALUE(@JsonObjectdata, '$.PriceListId') AS PriceListId,JSON_VALUE(@JsonObjectdata, '$.TenantId') AS TenantId,JSON_VALUE(@JsonObjectdata, '$.PriceListname') AS PriceListname,JSON_VALUE(@JsonObjectdata, '$.Createdby') AS Createdby,JSON_VALUE(@JsonObjectdata, '$.Modifiedby') AS Modifiedby,TRY_PARSE(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS DATETIME) AS Datemodified,TRY_PARSE(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS DATETIME) AS DateCreated
		) AS source ON target.PriceListId = source.PriceListId 
		WHEN MATCHED THEN UPDATE SET target.TenantId = source.TenantId,target.PriceListname = source.PriceListname,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
		WHEN NOT MATCHED THEN INSERT (TenantId,PriceListname,CreatedBy,ModifiedBy,DateCreated,DateModified)
		VALUES (source.TenantId,source.PriceListname,source.Createdby,source.Modifiedby,source.DateCreated,source.DateModified)
		OUTPUT inserted.PriceListId INTO @SystemPrices;
		SET @PriceListId = (SELECT PriceListId FROM @SystemPrices)

	
		-- Merge for the PriceListprices items
		MERGE INTO PriceListprices AS target
		USING (SELECT JSON_VALUE(items.value, '$.PriceListPricesId') AS PriceListPricesId,JSON_VALUE(items.value, '$.PriceListId') AS PriceListId,JSON_VALUE(@JsonObjectdata, '$.ProductvariationId') AS ProductvariationId,JSON_VALUE(@JsonObjectdata, '$.ProductPrice') AS ProductPrice,JSON_VALUE(@JsonObjectdata, '$.ProductVat') AS ProductVat,JSON_VALUE(items.value, '$.StationId') AS StationId
		FROM OPENJSON(@JsonObjectdata, '$.PriceListprices') AS items
		) AS source ON target.PriceListPricesId = source.PriceListPricesId -- Assuming ItemId is the unique identifier
		WHEN MATCHED THEN 
		UPDATE SET target.ProductvariationId = source.ProductvariationId,target.ProductPrice = source.ProductPrice,target.ProductVat = source.ProductVat,target.StationId = source.StationId
		WHEN NOT MATCHED THEN
		INSERT (PriceListId,ProductvariationId,ProductPrice,ProductVat,StationId)
		VALUES (@PriceListId,source.ProductvariationId,source.ProductPrice,source.ProductVat,source.StationId);
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
