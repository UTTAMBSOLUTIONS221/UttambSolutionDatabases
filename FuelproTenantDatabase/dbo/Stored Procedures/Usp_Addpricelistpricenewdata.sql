CREATE PROCEDURE [dbo].[Usp_Addpricelistpricenewdata]
    @JsonObjectdata VARCHAR(MAX)
AS
BEGIN
    DECLARE @RespStat INT = 0,
            @RespMsg VARCHAR(150) = '';

    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @PriceListPricesId INT = ISNULL((SELECT JSON_VALUE(@JsonObjectdata, '$.PriceListPricesId')), 0);
        DECLARE @PriceListId INT = ISNULL((SELECT JSON_VALUE(@JsonObjectdata, '$.PriceListId')), 0);
        DECLARE @StationId INT = ISNULL((SELECT JSON_VALUE(@JsonObjectdata, '$.StationId')), 0);
        DECLARE @StationdataId NVARCHAR(MAX) = JSON_QUERY(@JsonObjectdata, '$.StationdataId');
        DECLARE @ProductvariationId INT = ISNULL((SELECT JSON_VALUE(@JsonObjectdata, '$.ProductvariationId')), 0);
        DECLARE @ProductPrice DECIMAL(18, 2) = ISNULL((SELECT JSON_VALUE(@JsonObjectdata, '$.ProductPrice')), 0);
		
            -- Delete rows that are no longer present in the JSON
            DELETE FROM PriceListprices WHERE PriceListId = @PriceListId  AND ProductvariationId= @ProductvariationId  AND StationId IN (SELECT value FROM OPENJSON(@StationdataId));
        -- Insert new row
            INSERT INTO PriceListprices (PriceListId, StationId, ProductvariationId, ProductPrice) 
            SELECT @PriceListId, StationId, @ProductvariationId, @ProductPrice 
            FROM OPENJSON(@StationdataId) WITH (StationId INT '$');



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
END