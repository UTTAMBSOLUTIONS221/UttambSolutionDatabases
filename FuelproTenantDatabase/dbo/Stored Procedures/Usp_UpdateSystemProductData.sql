CREATE PROCEDURE [dbo].[Usp_UpdateSystemProductData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;

		  UPDATE SystemProduct SET CategoryId=JSON_VALUE(@JsonObjectdata, '$.CategoryId'),UomId=JSON_VALUE(@JsonObjectdata, '$.UomId'),Productname=JSON_VALUE(@JsonObjectdata, '$.Productvariationname'),Productdescription=JSON_VALUE(@JsonObjectdata, '$.Productvariationname'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE ProductId=JSON_VALUE(@JsonObjectdata, '$.ProductId')
		 
		UPDATE SystemProductvariation SET Productvariationname=JSON_VALUE(@JsonObjectdata, '$.Productvariationname'),Barcode=JSON_VALUE(@JsonObjectdata, '$.Barcode'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE ProductvariationId=JSON_VALUE(@JsonObjectdata, '$.ProductvariationId')
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