CREATE PROCEDURE [dbo].[Usp_GetSystemPriceListsData]
@TenantId BIGINT,
@CustomerPriceDetails NVARCHAR(MAX) OUTPUT
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
		SET @CustomerPriceDetails =(
		SELECT(
		SELECT a.PriceListId,a.PriceListname,a.IsDefault,a.IsActive,a.IsDeleted,b.Firstname+' '+ b.Lastname AS Createdby,c.Firstname+' '+ c.Lastname Modifiedby,a.Datecreated,a.Datemodified,
		(
			SELECT aa.PriceListPricesId,bb.StationId,cc.ProductvariationId,cc.Productvariationname,bb.Sname AS Station,aa.ProductPrice FROM PriceListprices aa 
			INNER JOIN SystemStations bb ON aa.StationId=bb.StationId
			INNER JOIN SystemProductvariation cc ON aa.ProductvariationId=cc.ProductvariationId
			WHERE aa.PriceListId=a.PriceListId
			FOR JSON PATH
		) AS PricelistData
		FROM PriceList a
		INNER JOIN SystemStaffs b ON a.Createdby=b.UserId
		INNER JOIN SystemStaffs c ON a.Createdby=c.UserId
		WHERE a.TenantId=@TenantId
		FOR JSON PATH
		) AS CustomerPriceData
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)
		

	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

			SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerPriceDetails as CustomerPriceDetails;

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