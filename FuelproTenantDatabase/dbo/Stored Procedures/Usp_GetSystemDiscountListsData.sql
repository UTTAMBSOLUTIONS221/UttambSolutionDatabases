CREATE PROCEDURE [dbo].[Usp_GetSystemDiscountListsData]
@CustomerDiscountDetails NVARCHAR(MAX) OUTPUT
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
		SET @CustomerDiscountDetails =(
		SELECT(
			SELECT a.DiscountListId,a.DiscountListname,a.IsDefault,a.IsActive,a.IsDeleted,b.Fullname AS Createdby,c.Fullname Modifiedby,a.Datecreated,a.Datemodified,
			(
				SELECT aa.LnkDiscountProductId,bb.StationId,cc.ProductvariationId,cc.Productvariationname,aa.Daysapplicable,aa.Starttime,aa.Endtime,bb.Sname AS Station,aa.Discountvalue 
				FROM LnkDiscountProducts aa 
				LEFT JOIN SystemStations bb ON aa.StationId=bb.Tenantstationid
				LEFT JOIN SystemProductvariation cc ON aa.ProductvariationId=cc.ProductvariationId
				WHERE aa.DiscountlistId=a.DiscountListId
				FOR JSON PATH
			) AS DiscountData
			FROM DiscountList a
			INNER JOIN SystemStaffs b ON a.Createdby=b.UserId
			INNER JOIN SystemStaffs c ON a.Createdby=c.UserId
			FOR JSON PATH
		) AS CustomerDiscounts
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)
		
		
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerDiscountDetails as CustomerDiscountDetails;

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