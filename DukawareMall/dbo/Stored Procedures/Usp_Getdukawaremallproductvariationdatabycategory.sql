CREATE PROCEDURE [dbo].[Usp_Getdukawaremallproductvariationdatabycategory]
@CategoryId BIGINT
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
		 SELECT ISNULL(b.TenantproductId,a.SystemproductId) AS TenantproductId,ISNULL(b.ProductownerId,a.Createdby) AS ProductownerId,a.SystemproductId,ISNULL(j.DisplayName,'Dukaware Mall') AS DisplayName,ISNULL(b.Productbuyingprice,0) AS Productbuyingprice,ISNULL(b.Productsellingprice,0) AS Productsellingprice,ISNULL(b.Productoldsellingprice,0) AS Productoldsellingprice,ISNULL(b.Productdiscount,0) AS Productdiscount,ISNULL(b.Productunits,0) AS Productunits,CASE WHEN a.ProductimageUrl1 IS NOT NULL THEN a.ProductimageUrl1  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl1,
					CASE WHEN a.ProductimageUrl2 IS NOT NULL THEN a.ProductimageUrl2  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl2,CASE WHEN a.ProductimageUrl3 IS NOT NULL THEN a.ProductimageUrl3  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl3,
					CASE WHEN a.ProductimageUrl4 IS NOT NULL THEN a.ProductimageUrl4  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl4,CASE WHEN a.ProductimageUrl5 IS NOT NULL THEN a.ProductimageUrl5  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl5,
					c.CategoryId as SubcategoryId,c.Categoryname AS Subcategoryname,d.Categoryname,a.UomId,e.Uomname,g.BrandId,g.Brandname,g.BrandImageurl,a.Productname,
					  a.Productbarcode,ISNULL(a.Extra,'N/A') AS Extra,ISNULL(a.Extra1,'N/A') AS Extra1,ISNULL(a.Extra2,'N/A') AS Extra2,ISNULL(a.Extra3,'N/A') AS Extra3,ISNULL(a.Extra4,'N/A') AS Extra4,ISNULL(a.Extra5,'N/A') AS Extra5,ISNULL(a.Extra6,'N/A') AS Extra6,ISNULL(a.Extra7,'N/A') AS Extra7,ISNULL(a.Extra8,'N/A') AS Extra8,ISNULL(a.Extra9,'N/A') AS Extra9,ISNULL(a.Extra10,'N/A') AS Extra10,a.Isactive,a.Isdeleted,
					  a.Createdby,h.Firstname +' '+ h.Lastname  AS Createdbyname,a.Modifiedby, i.Firstname +' '+ i.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated
				  FROM Systemproduct a 
				  LEFT JOIN Tenantproduct b ON a.SystemproductId=b.SystemproductId
				  INNER JOIN ProductCategory c ON a.CategoryId=c.CategoryId
				  INNER JOIN ProductCategory d ON c.ParentId=d.CategoryId
				  INNER JOIN Productuom e ON a.UomId=e.UomId
				  INNER JOIN Productuom f ON e.ParentId=f.UomId
				  INNER JOIN Productbrand g ON a.BrandId=g.BrandId
				  INNER JOIN Systemstaffs h ON a.Createdby =h.Staffid
				  INNER JOIN Systemstaffs i ON a.Modifiedby =i.Staffid
				  LEFT JOIN SystemShops j ON b.ProductOwnerId =j.ShopId WHERE a.CategoryGroupId=@CategoryId
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