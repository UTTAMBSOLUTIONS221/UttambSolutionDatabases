
CREATE PROCEDURE [dbo].[Usp_Getsystemproductmainstoredata]
    @TenantId BIGINT,
	@StationId BIGINT
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
        SELECT DSMS.DryStockStoreId,DSMS.PurchaseId,DSMS.ProductVariationId,SPV.Productvariationname,DSMS.Quantity,CB.Firstname+' '+CB.Lastname AS Createdby,MB.Firstname+' '+MB.Lastname AS Modifiedby,DSMS.DateCreated,DSMS.DateModified
		FROM DryStockMainStore DSMS
		INNER JOIN ShiftPurchases SP ON DSMS.PurchaseId=SP.PurchaseId
		INNER JOIN Stationshifts SS ON SP.ShiftId=SS.ShiftId
		INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
		INNER JOIN SystemProductvariation SPV ON DSMS.ProductVariationId=SPV.ProductvariationId
		INNER JOIN SystemStaffs CB ON DSMS.Createdby=CB.Userid
		INNER JOIN SystemStaffs MB ON DSMS.Createdby=MB.Userid
		WHERE STS.Tenantid=@TenantId AND STS.StationId=@StationId
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage
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