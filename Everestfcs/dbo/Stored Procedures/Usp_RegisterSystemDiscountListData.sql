CREATE PROCEDURE [dbo].[Usp_RegisterSystemDiscountListData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@DiscountListId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		INSERT INTO DiscountList(TenantId,DiscountListname,CreatedBy,ModifiedBy,DateCreated,DateModified)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'), JSON_VALUE(@JsonObjectdata, '$.DiscountListname'),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))

		SET @DiscountListId = SCOPE_IDENTITY();


		--select * from lnkdiscountproducts
		 
		INSERT INTO LnkDiscountProducts(DiscountlistId,Daysapplicable,Starttime,Endtime,Discountvalue,ProductvariationId,Createdby,Modifiedby,Datecreated,Datemodified,StationId)
		SELECT @DiscountListId, JSON_VALUE(@JsonObjectdata, '$.DiscountListDays'),JSON_VALUE(@JsonObjectdata, '$.DiscountListStartTime'),
		JSON_VALUE(@JsonObjectdata, '$.DiscountListEndTime'),JSON_VALUE(@JsonObjectdata, '$.ProductDiscountValue'),JSON_VALUE(@JsonObjectdata, '$.ProductvariationId'),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2),StationId
		FROM OPENJSON (@JsonObjectdata, '$.DiscountListpricestations')
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
