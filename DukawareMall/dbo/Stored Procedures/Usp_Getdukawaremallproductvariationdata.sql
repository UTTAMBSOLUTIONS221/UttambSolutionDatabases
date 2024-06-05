CREATE PROCEDURE [dbo].[Usp_Getdukawaremallproductvariationdata]
  @DukawareMallProductDetails NVARCHAR(MAX) OUTPUT
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
				 SET @DukawareMallProductDetails = 
				 (SELECT  
				 @RespStat as RespStatus, 
				 @RespMsg as RespMessage,
				 'We are Happy to serve you' AS SalePromoMessage,
				 (
					SELECT a.AdvertId,a.Advertlink,a.Isvideo,a.Isactive,a.Isdeleted,a.Enddate,a.Datecreated 
					FROM Socialpesaadverts a 
					WHERE a.Isactive=1 
					FOR JSON PATH
			     ) AS Adverts,
				 (
				    SELECT b.CategoryGroupId AS BuyFromId,b.CategoryGroupName AS BuyFromName,b.Categorygroupimgurl AS BuyFromImageUrl FROM Productcategorygroup b
					FOR JSON PATH
			     ) AS BuyFromGroup,
				 (
					SELECT b.CategoryGroupId,b.CategoryGroupName,b.Categorygroupimgurl FROM Productcategorygroup b
					FOR JSON PATH
			     ) AS CategoryGroup
		   FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		  );
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@DukawareMallProductDetails AS DukawareMallProductDetails;

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