CREATE PROCEDURE [dbo].[Usp_Updatesystemproductimagedata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.Productimagecolumn')='Productimageurl1')
		BEGIN
		    UPDATE Systemproduct  SET Productimageurl1=JSON_VALUE(@JsonObjectdata, '$.Productimageurl') WHERE SystemproductId=JSON_VALUE(@JsonObjectdata, '$.ProductId')
			Set @RespMsg ='Product Updated Successfully.'
		    Set @RespStat =0; 
		END
		ELSE IF(JSON_VALUE(@JsonObjectdata, '$.Productimagecolumn')='Productimageurl2')
		BEGIN
		  UPDATE Systemproduct  SET Productimageurl2=JSON_VALUE(@JsonObjectdata, '$.Productimageurl') WHERE SystemproductId=JSON_VALUE(@JsonObjectdata, '$.ProductId')
			Set @RespMsg ='Product Updated Successfully.'
		    Set @RespStat =0; 
		END
		ELSE IF(JSON_VALUE(@JsonObjectdata, '$.Productimagecolumn')='Productimageurl3')
		BEGIN
		  UPDATE Systemproduct  SET Productimageurl3=JSON_VALUE(@JsonObjectdata, '$.Productimageurl') WHERE SystemproductId=JSON_VALUE(@JsonObjectdata, '$.ProductId')
			Set @RespMsg ='Product Updated Successfully.'
		    Set @RespStat =0; 
		END
		ELSE IF(JSON_VALUE(@JsonObjectdata, '$.Productimagecolumn')='Productimageurl4')
		BEGIN
		  UPDATE Systemproduct  SET Productimageurl4=JSON_VALUE(@JsonObjectdata, '$.Productimageurl') WHERE SystemproductId=JSON_VALUE(@JsonObjectdata, '$.ProductId')
			Set @RespMsg ='Product Updated Successfully.'
		    Set @RespStat =0; 
		END
		ELSE 
		BEGIN
		  UPDATE Systemproduct  SET Productimageurl5=JSON_VALUE(@JsonObjectdata, '$.Productimageurl') WHERE SystemproductId=JSON_VALUE(@JsonObjectdata, '$.ProductId')
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