﻿
--EXEC Usp_GetSystemCustomerDetailData @CustomerId=51,@CustomerDetails=''


CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAgreementPriceListDetailData]
	@PriceListId BIGINT,
	@PriceListDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	

		
		BEGIN TRANSACTION;
		SET @PriceListDetails =(
			SELECT a.PriceListId,a.PriceListname,a.IsDefault,a.IsActive,a.IsDeleted,b.Fullname AS Createdby, c.Fullname AS Modifiedby,a.Datecreated,a.Datemodified,
			(
			  SELECT aa.PriceListPricesId,aa.PriceListId,aa.StationId,bb.Sname AS Station,aa.ProductvariationId,cc.Productvariationname,aa.ProductPrice
			  FROM PriceListprices aa
			  INNER JOIN SystemStations bb ON aa.StationId=bb.Tenantstationid
			  INNER JOIN SystemProductvariation cc ON aa.ProductvariationId=cc.ProductvariationId
			  WHERE a.PriceListId=aa.PriceListId
			  FOR JSON PATH
			) AS Pricelistprices
		  FROM PriceList a 
		  INNER JOIN SystemStaffs b ON a.Createdby=b.UserId
		  INNER JOIN SystemStaffs c ON a.Modifiedby=c.UserId
		 WHERE a.PriceListId =@PriceListId
		 FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@PriceListDetails as PriceListDetails;

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