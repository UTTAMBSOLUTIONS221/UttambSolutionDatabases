
--EXEC Usp_Getsystemproductmanagementdata @Productmanagementdata=''


CREATE PROCEDURE [dbo].[Usp_Getsystemproductmanagementdata]
	@Productmanagementdata NVARCHAR(MAX) OUTPUT
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
		SET @Productmanagementdata =(SELECT  
			(
			  SELECT CategoryGroupId,CategoryGroupName,Categorygroupimgurl FROM Productcategorygroup 
			 FOR JSON PATH
			) AS Productcategorygroup,
			(
			  SELECT a.UomId,a.Uomname,a.Uomsymbol,a.Isactive,a.Isdeleted,a.Createdby, b.Firstname +''+ b.Lastname AS Createdbyname,
			  a.Modifiedby, c.Firstname +''+ c.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated
			  FROM Productuom a
			  INNER JOIN Systemstaffs b ON a.Createdby =b.Staffid
			  INNER JOIN Systemstaffs c ON a.Modifiedby =c.Staffid
			 FOR JSON PATH
			) AS Productuoms,
			(
			 SELECT a.BrandId,a.Brandname,a.Brandimageurl,a.Isactive,a.Isdeleted,a.Createdby,b.Firstname +''+ b.Lastname AS Createdbyname,
			   a.Modifiedby, c.Firstname +''+ c.Lastname  AS Modifiedbyname,a.Datemodified,a.Datecreated
			FROM Productbrand a
			INNER JOIN Systemstaffs b ON a.Createdby =b.Staffid
			INNER JOIN Systemstaffs c ON a.Modifiedby =c.Staffid
			 FOR JSON PATH
			) AS Productbrands,
			(
			  SELECT a.CategoryId,a.Categoryname AS Subcategoryname,(CASE WHEN d.ParentId=0 THEN d.Categoryname ELSE a.Categoryname END) AS Categoryname,a.Isactive,a.Isdeleted,a.Createdby, b.Firstname +''+ b.Lastname  AS Createdbyname,
			    a.Modifiedby, c.Firstname +''+ c.Lastname  AS Modifiedbyname,a.Datemodified,a.Datecreated
			  FROM Productcategory a
			  INNER JOIN Systemstaffs b ON a.Createdby =b.Staffid
			  INNER JOIN Systemstaffs c ON a.Modifiedby =c.Staffid
			  LEFT JOIN Productcategory d ON a.ParentId =d.CategoryId
			 FOR JSON PATH
			) AS Productcategory
			
			FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)


	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@Productmanagementdata as Productmanagementdata;

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