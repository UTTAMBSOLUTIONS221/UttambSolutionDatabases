CREATE PROCEDURE [dbo].[Usp_Registertenantproductdata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.TenantproductId')=0)
		BEGIN
		INSERT INTO Tenantproduct(ProductownerId,SystemproductId,Productbuyingprice,Productoldsellingprice,Productsellingprice,Productdiscount,Productunits,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.ProductownerId'),JSON_VALUE(@JsonObjectdata, '$.SystemproductId'),JSON_VALUE(@JsonObjectdata, '$.Productsellingprice'),JSON_VALUE(@JsonObjectdata, '$.Productsellingprice'),JSON_VALUE(@JsonObjectdata, '$.Productsellingprice'),JSON_VALUE(@JsonObjectdata, '$.Productdiscount'),JSON_VALUE(@JsonObjectdata, '$.Productunits'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),
		JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		JSON_VALUE(@JsonObjectdata, '$.Extra9'),JSON_VALUE(@JsonObjectdata, '$.Extra10'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),
		JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		Set @RespMsg ='Product Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Tenantproduct 
		SET SystemproductId=JSON_VALUE(@JsonObjectdata, '$.SystemproductId'),Productoldsellingprice=(SELECT Productsellingprice FROM Tenantproduct WHERE TenantproductId=JSON_VALUE(@JsonObjectdata, '$.TenantproductId')),Productsellingprice=JSON_VALUE(@JsonObjectdata, '$.Productsellingprice'),Productdiscount=JSON_VALUE(@JsonObjectdata, '$.Productdiscount'),Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),
		Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE TenantproductId=JSON_VALUE(@JsonObjectdata, '$.TenantproductId')
		Set @RespMsg ='Product Updated Successfully.'
		Set @RespStat =0; 
		END
		
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage;

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