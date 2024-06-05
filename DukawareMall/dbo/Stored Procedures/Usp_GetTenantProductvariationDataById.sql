CREATE PROCEDURE [dbo].[Usp_GetTenantProductvariationDataById]
	@ProductId BIGINT
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
			SELECT a.TenantproductId,a.ProductownerId,a.SystemproductId,a.Productbuyingprice,a.Productsellingprice,a.Productoldsellingprice,a.Productdiscount,a.Productunits,b.Productimageurl1,b.Productimageurl2,b.Productimageurl3,b.Productimageurl4,b.Productimageurl5,
			  c.CategoryId as SubcategoryId,c.Categoryname AS Subcategoryname,d.Categoryname,b.UomId,e.Uomname,g.BrandId,g.Brandname,g.BrandImageurl,b.Productname,
			  b.Productbarcode,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Isactive,a.Isdeleted,
			  a.Createdby,h.Firstname +' '+ h.Lastname  AS Createdbyname,a.Modifiedby, i.Firstname +' '+ i.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated
		  FROM Tenantproduct a 
		  INNER JOIN Systemproduct b ON a.SystemproductId=b.SystemproductId
		  INNER JOIN ProductCategory c ON b.CategoryId=c.CategoryId
		  INNER JOIN ProductCategory d ON c.ParentId=d.CategoryId
		  INNER JOIN Productuom e ON b.UomId=e.UomId
		   INNER JOIN Productuom f ON e.ParentId=f.UomId
		  INNER JOIN Productbrand g ON b.BrandId=g.BrandId
		  INNER JOIN Systemstaffs h ON a.Createdby =h.Staffid
		  INNER JOIN Systemstaffs i ON a.Modifiedby =i.Staffid WHERE a.SystemproductId=@ProductId
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