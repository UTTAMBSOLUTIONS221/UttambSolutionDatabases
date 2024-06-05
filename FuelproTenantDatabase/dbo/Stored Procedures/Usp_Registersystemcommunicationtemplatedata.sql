CREATE PROCEDURE [dbo].[Usp_Registersystemcommunicationtemplatedata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.Templateid')=0)
		BEGIN
		INSERT INTO Communicationtemplates(Templatename,Templatesubject,Templatebody,Isactive,Isdeleted,Isemailsms)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Templatename'),JSON_VALUE(@JsonObjectdata, '$.Templatesubject'),JSON_VALUE(@JsonObjectdata, '$.Templatebody'),1,0,JSON_VALUE(@JsonObjectdata, '$.Isemailsms'))

		Set @RespMsg ='Communication Temlate Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Communicationtemplates 
		SET Templatename=JSON_VALUE(@JsonObjectdata, '$.Templatename'),Templatesubject=JSON_VALUE(@JsonObjectdata, '$.Templatesubject'),
		Templatebody=JSON_VALUE(@JsonObjectdata, '$.Templatebody'),Isemailsms=JSON_VALUE(@JsonObjectdata, '$.Isemailsms') WHERE Templateid =JSON_VALUE(@JsonObjectdata, '$.Templateid')

		Set @RespMsg ='Communication Temlate Updated Successfully.'
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