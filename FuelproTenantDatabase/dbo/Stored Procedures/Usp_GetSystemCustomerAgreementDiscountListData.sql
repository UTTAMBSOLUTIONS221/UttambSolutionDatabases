
--EXEC Usp_GetSystemCustomerAgreementPriceListDetailData @PriceListId=1,@PriceListDetails=''


CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAgreementDiscountListData]
	@DiscountListId BIGINT,
	@DiscountListDetails NVARCHAR(MAX) OUTPUT
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
		SET @DiscountListDetails =(
			SELECT a.DiscountListId,a.DiscountListname,a.IsDefault,a.IsActive,a.IsDeleted,b.Fullname AS Createdby, c.Fullname AS Modifiedby,a.Datecreated,a.Datemodified,
			(
			  SELECT aa.LnkDiscountProductId,aa.StationId,c.ProductvariationId,c.Productvariationname,aa.Daysapplicable,aa.Starttime,aa.Endtime,bb.Sname AS Station,aa.Discountvalue FROM LnkDiscountProducts aa 
				 INNER JOIN SystemStations bb ON aa.StationId=bb.Tenantstationid
				INNER JOIN SystemProductvariation c ON aa.ProductvariationId=c.ProductvariationId
			  WHERE a.DiscountListId=aa.DiscountlistId
			  FOR JSON PATH
			) AS Discountlistvalues
		  FROM DiscountList a 
		   INNER JOIN SystemStaffs b ON a.Createdby=b.UserId
		  INNER JOIN SystemStaffs c ON a.Modifiedby=c.UserId
		 WHERE a.DiscountListId =@DiscountListId
		 FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@DiscountListDetails as DiscountListDetails;

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