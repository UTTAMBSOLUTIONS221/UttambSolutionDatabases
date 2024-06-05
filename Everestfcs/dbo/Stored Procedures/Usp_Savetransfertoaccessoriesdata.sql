CREATE PROCEDURE [dbo].[Usp_Savetransfertoaccessoriesdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@ShiftId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		 SET @ShiftId=(SELECT TOP 1 ShiftId FROM Stationshifts WHERE ShiftStatus=0);
		 IF(JSON_VALUE(@JsonObjectdata, '$.Movement')='Transfertoaccessories')
		 BEGIN
		  INSERT INTO DryStockMovement(DryStockStoreId,ProductVariationId,ShiftId,Quantity,Movement,Createdby,Modifiedby,DateCreated,DateModified)
		  SELECT JSON_VALUE(@JsonObjectdata, '$.DryStockStoreId'),JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),@ShiftId,JSON_VALUE(@JsonObjectdata, '$.Quantity'),JSON_VALUE(@JsonObjectdata, '$.Movement'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated')  AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
		  UPDATE DryStockMainStore SET Quantity= Quantity-JSON_VALUE(@JsonObjectdata, '$.Quantity') WHERE DryStockStoreId=JSON_VALUE(@JsonObjectdata, '$.DryStockStoreId');
		 END
		 ELSE
		 BEGIN
		  INSERT INTO DryStockMovement(DryStockStoreId,ProductVariationId,ShiftId,Quantity,Movement,Createdby,Modifiedby,DateCreated,DateModified)
		  SELECT JSON_VALUE(@JsonObjectdata, '$.DryStockStoreId'),JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),@ShiftId, -1 * CAST(JSON_VALUE(@JsonObjectdata, '$.Quantity') AS decimal(18, 2)),JSON_VALUE(@JsonObjectdata, '$.Movement'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated')  AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
		  UPDATE DryStockMainStore SET Quantity= Quantity+JSON_VALUE(@JsonObjectdata, '$.Quantity') WHERE DryStockStoreId=JSON_VALUE(@JsonObjectdata, '$.DryStockStoreId');
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