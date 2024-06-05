CREATE PROCEDURE [dbo].[Usp_Getsystemproductdatadetailbyid]
@SystemproductId BIGINT,
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
		   SET @DukawareMallProductDetails = (SELECT  a.SystemproductId,a.CategoryId,b.Categoryname AS Subcategoryname,c.Categoryname,a.UomId,d.Uomname,a.BrandId,e.Brandname,e.BrandImageurl,a.Productname,ISNULL(i.Productbuyingprice,0) AS Productbuyingprice,ISNULL(i.Productsellingprice,0) AS Productsellingprice,
		  ISNULL(i.Productdiscount,0) AS Productdiscount,ISNULL(i.Productunits,0) AS Productunits, a.Productbarcode,ISNULL(a.Wholesaleprice,0) AS Wholesaleprice,ISNULL(a.Marketsaleprice,0) AS Marketsaleprice,a.Productimageurl1,a.Productimageurl2,a.Productimageurl3,a.Productimageurl4,a.Productimageurl5,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Isactive,a.Isdeleted,
		 f.Firstname +' '+ f.Lastname  AS Createdbyname,a.Modifiedby, g.Firstname +' '+ g.Lastname AS Modifiedbyname,
		  a.Datemodified,a.Datecreated,
		  (
		    SELECT bb.DescriptionId,bb.SystemproductId,bb.Descriptiondata,bb.Isactive,bb.Isdeleted,bb.Createdby,bb.Modifiedby,
			f.Firstname +' '+ f.Lastname  AS Createdbyname,g.Firstname +' '+ g.Lastname AS Modifiedbyname,bb.Datemodified,bb.Datecreated
			FROM Systemproductdescription bb
			INNER JOIN Systemstaffs f ON bb.Createdby =f.Staffid
		     INNER JOIN Systemstaffs g ON bb.Modifiedby =g.Staffid
			WHERE bb.SystemproductId=a.SystemproductId
			FOR JSON PATH
			) AS Productdescriptions,
		  (
		     SELECT cc.SpecificationId,cc.SystemproductId,cc.Specificationdata,cc.Isactive,cc.Isdeleted,cc.Createdby,cc.Modifiedby,f.Firstname +' '+ f.Lastname  AS Createdbyname,g.Firstname +' '+ g.Lastname AS Modifiedbyname,cc.Datemodified,cc.Datecreated
			 FROM Systemproductspecification cc
			 INNER JOIN Systemstaffs f ON cc.Createdby =f.Staffid
		     INNER JOIN Systemstaffs g ON cc.Modifiedby =g.Staffid
			 WHERE cc.SystemproductId=a.SystemproductId
			FOR JSON PATH
		  ) AS Productspecifications,
		  (
		  SELECT dd.WhatsinboxId,dd.SystemproductId,dd.Itemname,dd.Isactive,dd.Isdeleted,dd.Createdby,dd.Modifiedby,f.Firstname +' '+ f.Lastname  AS Createdbyname,g.Firstname +' '+ g.Lastname AS Modifiedbyname,dd.Datemodified,dd.Datecreated
          FROM Systemproductwhatsinbox dd
		  INNER JOIN Systemstaffs f ON dd.Createdby =f.Staffid
		     INNER JOIN Systemstaffs g ON dd.Modifiedby =g.Staffid
		   WHERE dd.SystemproductId=a.SystemproductId
			FOR JSON PATH
		  ) AS Productwhatsinbox
		  FROM Systemproduct a
		  INNER JOIN ProductCategory b ON a.CategoryId=b.CategoryId
		  INNER JOIN ProductCategory c ON b.ParentId=c.CategoryId
		  INNER JOIN Productuom d ON a.UomId=d.UomId
		   INNER JOIN Productuom h ON d.ParentId=h.UomId
		  INNER JOIN Productbrand e ON a.BrandId=e.BrandId
		  INNER JOIN Systemstaffs f ON a.Createdby =f.Staffid
		  INNER JOIN Systemstaffs g ON a.Modifiedby =g.Staffid
		  LEFT JOIN TenantProduct i ON i.SystemproductId=a.SystemproductId
		  WHERE  a.SystemproductId=@SystemproductId
		   FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		  );
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