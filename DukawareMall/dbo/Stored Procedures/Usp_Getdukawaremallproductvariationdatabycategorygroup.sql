CREATE PROCEDURE [dbo].[Usp_Getdukawaremallproductvariationdatabycategorygroup]
  @CategoryGroupId BIGINT,
  @DukawareMallProductDetailsByCategoryGroup NVARCHAR(MAX) OUTPUT
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
				 SET @DukawareMallProductDetailsByCategoryGroup = (SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,
				 
				 (
				   SELECT a.TenantproductId,a.ProductownerId,a.SystemproductId,j.DisplayName,a.Productbuyingprice,a.Productsellingprice,a.Productoldsellingprice,a.Productdiscount,a.Productunits,CASE WHEN b.ProductimageUrl1 IS NOT NULL THEN b.ProductimageUrl1  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl1,
					CASE WHEN b.ProductimageUrl2 IS NOT NULL THEN b.ProductimageUrl2  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl2,CASE WHEN b.ProductimageUrl3 IS NOT NULL THEN b.ProductimageUrl3  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl3,
					CASE WHEN b.ProductimageUrl4 IS NOT NULL THEN b.ProductimageUrl4  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl4,CASE WHEN b.ProductimageUrl5 IS NOT NULL THEN b.ProductimageUrl5  ELSE 'https://www.lenarjisse.com/images/no-image.png' END AS ProductimageUrl5,
					c.CategoryId as SubcategoryId,b.CategoryGroupId,c.Categoryname AS Subcategoryname,d.Categoryname,b.UomId,e.Uomname,g.BrandId,g.Brandname,g.BrandImageurl,b.Productname,
					  b.Productbarcode,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Isactive,a.Isdeleted,
					  a.Createdby,h.Firstname +' '+ h.Lastname  AS Createdbyname,a.Modifiedby, i.Firstname +' '+ i.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated,
					  (
						SELECT bb.DescriptionId,bb.SystemproductId,bb.Descriptiondata,bb.Isactive,bb.Isdeleted,bb.Createdby,bb.Modifiedby,
						f.Firstname +' '+ f.Lastname  AS Createdbyname,g.Firstname +' '+ g.Lastname AS Modifiedbyname,bb.Datemodified,bb.Datecreated
						FROM Systemproductdescription bb
						INNER JOIN Systemstaffs f ON bb.Createdby =f.Staffid
						 INNER JOIN Systemstaffs g ON bb.Modifiedby =g.Staffid
						WHERE bb.SystemproductId=b.SystemproductId
						FOR JSON PATH
						) AS Productdescriptions,
					  (
						 SELECT cc.SpecificationId,cc.SystemproductId,cc.Specificationdata,cc.Isactive,cc.Isdeleted,cc.Createdby,cc.Modifiedby,f.Firstname +' '+ f.Lastname  AS Createdbyname,g.Firstname +' '+ g.Lastname AS Modifiedbyname,cc.Datemodified,cc.Datecreated
						 FROM Systemproductspecification cc
						 INNER JOIN Systemstaffs f ON cc.Createdby =f.Staffid
						 INNER JOIN Systemstaffs g ON cc.Modifiedby =g.Staffid
						 WHERE cc.SystemproductId=b.SystemproductId
						FOR JSON PATH
					  ) AS Productspecifications,
					  (
					  SELECT dd.WhatsinboxId,dd.SystemproductId,dd.Itemname,dd.Isactive,dd.Isdeleted,dd.Createdby,dd.Modifiedby,f.Firstname +' '+ f.Lastname  AS Createdbyname,g.Firstname +' '+ g.Lastname AS Modifiedbyname,dd.Datemodified,dd.Datecreated
					  FROM Systemproductwhatsinbox dd
					  INNER JOIN Systemstaffs f ON dd.Createdby =f.Staffid
						 INNER JOIN Systemstaffs g ON dd.Modifiedby =g.Staffid
					   WHERE dd.SystemproductId=b.SystemproductId
						FOR JSON PATH
					  ) AS Productwhatsinbox
				 FROM Tenantproduct a 
					INNER JOIN Systemproduct b ON a.SystemproductId=b.SystemproductId
					INNER JOIN ProductCategory c ON b.CategoryId=c.CategoryId
					INNER JOIN ProductCategory d ON b.SubCategoryId=d.CategoryId
					INNER JOIN Productuom e ON b.UomId=e.UomId
					INNER JOIN Productuom f ON b.UomItemId=f.UomId
					INNER JOIN Productbrand g ON b.BrandId=g.BrandId
					INNER JOIN Systemstaffs h ON a.Createdby =h.Staffid
					INNER JOIN Systemstaffs i ON a.Modifiedby =i.Staffid
					LEFT JOIN SystemShops j ON a.ProductOwnerId =j.ShopId
					WHERE b.CategoryGroupId=@CategoryGroupId
				   FOR JSON PATH
				  ) AS ProductVariations
				   FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
				  );
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@DukawareMallProductDetailsByCategoryGroup AS DukawareMallProductDetailsByCategoryGroup;

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