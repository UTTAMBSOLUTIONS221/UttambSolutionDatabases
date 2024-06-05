CREATE PROCEDURE [dbo].[Usp_Registersystemproductorderdata]
@JsonObjectdata VARCHAR(MAX),
@ProductOrderDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Orderdetailid BIGINT,
			@Odernumber VARCHAR(100);
		  
	BEGIN
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		Select @Odernumber = dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID)
		INSERT INTO Orderdetaildata(Odernumber,Orderownerid,Orderamount,Orderunits,Orderstatus,Isactive,Isdeleted,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Orderdate,Datecreated)
	    (SELECT @Odernumber,JSON_VALUE(@JsonObjectdata, '$.OrderOwnerId'),JSON_VALUE(@JsonObjectdata, '$.OrderAmount'),JSON_VALUE(@JsonObjectdata, '$.OrderUnits'),2,1,0,
		JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),JSON_VALUE(@JsonObjectdata, '$.Extra9'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.OrderDate') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated')  AS datetime2))

		SET @Orderdetailid = SCOPE_IDENTITY();

		INSERT INTO Orderdetailitemdata (Orderdetailid,Productid,Shopid,Productunit,Unitprice)
        SELECT @OrderDetailId, JSON_VALUE(items.value, '$.Product.TenantProductId'),JSON_VALUE(items.value, '$.Product.ProductOwnerId'), JSON_VALUE(items.value, '$.Quantity'),JSON_VALUE(items.value, '$.Product.ProductSellingPrice')
       FROM OPENJSON(@JsonObjectdata, '$.OrderItems') AS items;

        SET @ProductOrderDetails = (SELECT  @RespStat as RespStatus, @RespMsg as RespMessage, a.Orderdetailid,a.Odernumber,a.Orderownerid,b.Firstname +' '+ b.Lastname AS Fullname,a.Orderamount,a.Orderunits,CASE WHEN a.Orderstatus=2 THEN 'Recieved' WHEN  a.Orderstatus=1 THEN 'Processed' ELSE 'Completed' END AS Orderstatus,a.Isactive,a.Isdeleted,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Orderdate,a.Datecreated,
		(SELECT aa.Orderdetailitemid,aa.Orderdetailid,aa.Productid,cc.Productname,ee.Brandimageurl,cc.Productimageurl1,aa.Shopid,dd.DisplayName,aa.Productunit,aa.Unitprice
		  FROM Orderdetailitemdata aa INNER JOIN Tenantproduct bb ON aa.Productid=bb.TenantproductId INNER JOIN SystemProduct cc ON bb.SystemproductId=cc.SystemproductId INNER JOIN Systemshops dd ON aa.Shopid=dd.ShopId INNER JOIN Productbrand ee ON cc.BrandId=ee.BrandId
		  WHERE a.Orderdetailid =aa.Orderdetailid FOR JSON PATH ) AS Orderdetailitemdata
		FROM Orderdetaildata a
		INNER JOIN Systemstaffs b ON a.Orderownerid=b.StaffId
		WHERE a.Orderdetailid=@Orderdetailid
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		);
		 
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @ProductOrderDetails AS ProductOrderDetails;

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