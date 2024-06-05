CREATE PROCEDURE [dbo].[Usp_Registersystemproductdata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.SystemproductId')=0)
		BEGIN
		INSERT INTO Systemproduct(CategoryGroupId,CategoryId,SubCategoryId,UomId,UomItemId,BrandId,Productname,Productbarcode,Wholesaleprice,Marketsaleprice,ProductimageUrl1,ProductimageUrl2,ProductimageUrl3,ProductimageUrl4,ProductimageUrl5,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.CategoryGroupId'),JSON_VALUE(@JsonObjectdata, '$.CategoryId'),JSON_VALUE(@JsonObjectdata, '$.SubCategoryId'),JSON_VALUE(@JsonObjectdata, '$.UomId'),JSON_VALUE(@JsonObjectdata, '$.UomItemId'),JSON_VALUE(@JsonObjectdata, '$.BrandId'),JSON_VALUE(@JsonObjectdata, '$.Productname'),
		JSON_VALUE(@JsonObjectdata, '$.Productbarcode'),JSON_VALUE(@JsonObjectdata, '$.Wholesaleprice'),JSON_VALUE(@JsonObjectdata, '$.Marketsaleprice'),JSON_VALUE(@JsonObjectdata, '$.Productimageurl1'),JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl2'),
		JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl3'),JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl4'),JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl5'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		JSON_VALUE(@JsonObjectdata, '$.Extra9'),JSON_VALUE(@JsonObjectdata, '$.Extra10'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),
		JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		Set @RespMsg ='Product Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Systemproduct 
		SET CategoryGroupId=JSON_VALUE(@JsonObjectdata, '$.CategoryGroupId'),CategoryId=JSON_VALUE(@JsonObjectdata, '$.CategoryId'),SubCategoryId=JSON_VALUE(@JsonObjectdata, '$.SubCategoryId'),UomId=JSON_VALUE(@JsonObjectdata, '$.UomId'),UomItemId=JSON_VALUE(@JsonObjectdata, '$.UomItemId'),BrandId=JSON_VALUE(@JsonObjectdata, '$.BrandId'),Productname=JSON_VALUE(@JsonObjectdata, '$.Productname'),
		Productbarcode=JSON_VALUE(@JsonObjectdata, '$.Productbarcode'),Wholesaleprice=JSON_VALUE(@JsonObjectdata, '$.Wholesaleprice'),Marketsaleprice=JSON_VALUE(@JsonObjectdata, '$.Marketsaleprice'),ProductimageUrl1=JSON_VALUE(@JsonObjectdata, '$.Productimageurl1'),ProductimageUrl2=JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl2'),
		ProductimageUrl3=JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl3'),ProductimageUrl4=JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl4'),ProductimageUrl5=JSON_VALUE(@JsonObjectdata, '$.ProductimageUrl5'),Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE SystemproductId=JSON_VALUE(@JsonObjectdata, '$.SystemproductId')
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