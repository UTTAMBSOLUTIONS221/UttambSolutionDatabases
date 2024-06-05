CREATE PROCEDURE [dbo].[Usp_Registersystemproductbranddata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.BrandId')=0)
		BEGIN
		INSERT INTO Productbrand(Brandname,Brandimageurl,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Brandname'),JSON_VALUE(@JsonObjectdata, '$.Brandimageurl'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),
		JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		Set @RespMsg ='Product Brand Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Productbrand 
		SET Brandname=JSON_VALUE(@JsonObjectdata, '$.Brandname'),Brandimageurl=JSON_VALUE(@JsonObjectdata, '$.Brandimageurl'),
		Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE BrandId =JSON_VALUE(@JsonObjectdata, '$.BrandId')

		Set @RespMsg ='Product Brand Updated Successfully.'
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