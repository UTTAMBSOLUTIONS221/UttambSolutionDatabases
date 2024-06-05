CREATE PROCEDURE [dbo].[Usp_Updatesystemblogdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Systemblogid BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		UPDATE  Fortysevennewsblogs SET Systemblogtitle=JSON_VALUE(@JsonObjectdata, '$.Systemblogtitle'),Systemblogdescription=JSON_VALUE(@JsonObjectdata, '$.Systemblogdescription'),Systemblogcategoryid=JSON_VALUE(@JsonObjectdata, '$.Systemblogcategoryid'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE Systemblogid=JSON_VALUE(@JsonObjectdata, '$.Systemblogid')
		
		Set @RespMsg ='Success'
		Set @RespStat =0; 
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