CREATE PROCEDURE [dbo].[Usp_Gettenantorderdetaildatabyid]
 @OrderDetailId BIGINT,
 @ProductOrderDetails NVARCHAR(MAX) OUTPUT
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
		 SET @ProductOrderDetails = (SELECT  @RespStat as RespStatus, @RespMsg as RespMessage, a.Orderdetailid,a.Odernumber,a.Orderownerid,b.Firstname +' '+ b.Lastname AS Fullname,a.Orderamount,a.Orderunits,CASE WHEN a.Orderstatus=2 THEN 'Recieved' WHEN  a.Orderstatus=1 THEN 'Processed' ELSE 'Completed' END AS Orderstatus,a.Isactive,a.Isdeleted,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Orderdate,a.Datecreated,
		(SELECT aa.Orderdetailitemid,aa.Orderdetailid,aa.Productid,cc.Productname,ee.Brandimageurl,cc.Productimageurl1,aa.Shopid,dd.DisplayName,aa.Productunit,aa.Unitprice
		  FROM Orderdetailitemdata aa INNER JOIN Tenantproduct bb ON aa.Productid=bb.TenantproductId INNER JOIN SystemProduct cc ON bb.SystemproductId=cc.SystemproductId INNER JOIN Systemshops dd ON aa.Shopid=dd.ShopId INNER JOIN Productbrand ee ON cc.BrandId=ee.BrandId
		  WHERE a.Orderdetailid =aa.Orderdetailid FOR JSON PATH ) AS Orderdetailitemdata
		FROM Orderdetaildata a
		INNER JOIN Systemstaffs b ON a.Orderownerid=b.StaffId
		WHERE a.Orderdetailid=@OrderDetailId
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		);
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@ProductOrderDetails AS ProductOrderDetails

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