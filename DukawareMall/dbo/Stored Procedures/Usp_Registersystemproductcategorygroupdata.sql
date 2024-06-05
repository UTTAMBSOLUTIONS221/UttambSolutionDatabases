CREATE PROCEDURE [dbo].[Usp_Registersystemproductcategorygroupdata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Categorygroupimgurl VARCHAR(200);
			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.Categorygroupimgurl') IS NULL OR JSON_VALUE(@JsonObjectdata, '$.Categorygroupimgurl')='')
		BEGIN
		SET @Categorygroupimgurl='https://www.lenarjisse.com/images/no-image.png';
		END
		ELSE
		BEGIN
		SET @Categorygroupimgurl=JSON_VALUE(@JsonObjectdata, '$.Categorygroupimgurl') ;
		END

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.CategoryGroupId')=0)
		BEGIN
		INSERT INTO Productcategorygroup(CategoryGroupName,Categorygroupimgurl)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.CategoryGroupName'),@Categorygroupimgurl)

		Set @RespMsg ='Product Category Group Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Productcategorygroup 
		SET CategoryGroupName=JSON_VALUE(@JsonObjectdata, '$.CategoryGroupName'),Categorygroupimgurl=@Categorygroupimgurl WHERE CategoryGroupId=JSON_VALUE(@JsonObjectdata, '$.CategoryGroupId')
		Set @RespMsg ='Product Category Group Updated Successfully.'
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