CREATE PROCEDURE [dbo].[Usp_Registersystemblogcategorydata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.BlogCategoryId')=0)
		BEGIN
		INSERT INTO BlogCategory(BlogCategoryName,CreatedBy,ModifiedBy,DateCreated,DateModified)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.BlogCategoryName'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2))
		Set @RespMsg ='Blog Category Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE BlogCategory SET BlogCategoryName=JSON_VALUE(@JsonObjectdata, '$.BlogCategoryName'),ModifiedBy=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2) WHERE BlogCategoryId=JSON_VALUE(@JsonObjectdata, '$.BlogCategoryId')
		Set @RespMsg ='Blog Category Updated Successfully.'
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