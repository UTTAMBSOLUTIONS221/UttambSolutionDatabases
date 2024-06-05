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
		INSERT INTO PriceList(PriceListname,CreatedBy,ModifiedBy,DateCreated,DateModified)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.PriceListname'),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))

		SET @PriceListId = SCOPE_IDENTITY();
		 
		INSERT INTO PriceListprices(PriceListId,ProductvariationId,ProductPrice,StationId)
		SELECT @PriceListId, JSON_VALUE(@JsonObjectdata, '$.ProductvariationId'),JSON_VALUE(@JsonObjectdata, '$.ProductPrice'),StationId
		FROM OPENJSON (@JsonObjectdata, '$.PriceListprices')
		WITH (
			StationId BIGINT
		)

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