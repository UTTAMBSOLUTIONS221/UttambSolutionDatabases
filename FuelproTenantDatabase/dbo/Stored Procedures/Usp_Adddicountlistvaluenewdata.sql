CREATE PROCEDURE [dbo].[Usp_Adddicountlistvaluenewdata]
    @JsonObjectdata VARCHAR(MAX)
AS
BEGIN
    DECLARE @RespStat INT = 0,
            @RespMsg VARCHAR(150) = '';

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Delete rows that are no longer present in the JSON
        DELETE FROM LnkDiscountProducts WHERE DiscountlistId = JSON_VALUE(@JsonObjectdata, '$.DiscountlistId') AND ProductvariationId = JSON_VALUE(@JsonObjectdata, '$.ProductvariationId') AND StationId IN (SELECT StationId FROM OPENJSON (@JsonObjectdata, '$.DiscountListpricestations') WITH (StationId BIGINT));

		INSERT INTO LnkDiscountProducts(DiscountlistId,Daysapplicable,Starttime,Endtime,Discountvalue,ProductvariationId,Createdby,Modifiedby,Datecreated,Datemodified,StationId)
		SELECT JSON_VALUE(@JsonObjectdata, '$.DiscountlistId'), JSON_VALUE(@JsonObjectdata, '$.Daysapplicable'),JSON_VALUE(@JsonObjectdata, '$.Starttime'),
		JSON_VALUE(@JsonObjectdata, '$.Endtime'),JSON_VALUE(@JsonObjectdata, '$.Discountvalue'),JSON_VALUE(@JsonObjectdata, '$.ProductvariationId'),
		JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2),StationId
		FROM OPENJSON (@JsonObjectdata, '$.DiscountListpricestations')
		WITH (
			StationId BIGINT
		)
        SET @RespMsg = 'Success';
        SET @RespStat = 0; 
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @RespMsg = 'Error - ' + ERROR_MESSAGE();
        SET @RespStat = 2;
    END CATCH

    SELECT @RespStat AS RespStatus, @RespMsg AS RespMessage;
END;