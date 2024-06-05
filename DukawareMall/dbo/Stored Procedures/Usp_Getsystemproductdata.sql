CREATE PROCEDURE [dbo].[Usp_Getsystemproductdata]
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
		  SELECT  a.SystemproductId,a.CategoryId,b.Categoryname AS Subcategoryname,c.Categoryname,a.UomId,d.Uomname,a.BrandId,e.Brandname,e.BrandImageurl,a.Productname,
		  a.Productbarcode,a.Wholesaleprice,a.Marketsaleprice,a.Productimageurl1,a.Productimageurl2,a.Productimageurl3,a.Productimageurl4,a.Productimageurl5,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Isactive,a.Isdeleted,
		 f.Firstname +' '+ f.Lastname  AS Createdbyname,a.Modifiedby, g.Firstname +' '+ g.Lastname AS Modifiedbyname,
		  a.Datemodified,a.Datecreated
		  FROM Systemproduct a
		  INNER JOIN ProductCategory b ON a.CategoryId=b.CategoryId
		  INNER JOIN ProductCategory c ON a.SubCategoryId=c.CategoryId
		  INNER JOIN Productuom d ON a.UomId=d.UomId
		  INNER JOIN Productuom h ON a.UomItemId=h.UomId
		  INNER JOIN Productbrand e ON a.BrandId=e.BrandId
		  INNER JOIN Systemstaffs f ON a.Createdby =f.Staffid
		  INNER JOIN Systemstaffs g ON a.Modifiedby =g.Staffid
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