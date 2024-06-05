﻿CREATE PROCEDURE [dbo].[Usp_DefaultThisTableColumnData]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE  
			@Sql NVARCHAR(1000),
			@Sql1 NVARCHAR(1000),
			@RespStat int = 0,
			@RespMsg varchar(150) = '';

			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		BEGIN
		  SET @Sql1 = 'UPDATE '+ JSON_VALUE(@JsonObjectdata, '$.Tablename') +' SET '+ JSON_VALUE(@JsonObjectdata, '$.Columname') + ' = ' + 0 + ' Where ' + JSON_VALUE(@JsonObjectdata, '$.Columnidname') + ' = '  + JSON_VALUE(@JsonObjectdata, '$.Entryid')
          exec sp_executesql @sql1

          SET @Sql = 'UPDATE '+ JSON_VALUE(@JsonObjectdata, '$.Tablename') +' SET '+ JSON_VALUE(@JsonObjectdata, '$.Columname') + ' = ' + JSON_VALUE(@JsonObjectdata, '$.Status') + ' Where ' + JSON_VALUE(@JsonObjectdata, '$.Columnidname') + ' = '  + JSON_VALUE(@JsonObjectdata, '$.Entryid')
          exec sp_executesql @sql
		END
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