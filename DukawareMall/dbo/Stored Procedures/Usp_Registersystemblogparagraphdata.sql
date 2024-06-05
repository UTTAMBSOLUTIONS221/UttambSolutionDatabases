CREATE PROCEDURE [dbo].[Usp_Registersystemblogparagraphdata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.Systemblogparagraphid')=0)
		BEGIN
		INSERT INTO Fortysevennewsblogparagraphs(Systemblogid,Systemblogparagraph)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Systemblogid'),JSON_VALUE(@JsonObjectdata, '$.Systemblogparagraph'))

		Set @RespMsg ='Blog Paragraph Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Fortysevennewsblogparagraphs 
		SET Systemblogparagraph=JSON_VALUE(@JsonObjectdata, '$.Systemblogparagraph') WHERE Systemblogparagraphid =JSON_VALUE(@JsonObjectdata, '$.Systemblogparagraphid')

		Set @RespMsg ='Blog Paragraph Updated Successfully.'
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