CREATE PROCEDURE [dbo].[Usp_Registersystemmodulesdata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.ModuleId')=0)
		BEGIN
		INSERT INTO Systemmodules(Modulename,Moduleemail,PhoneId,Modulephone,Modulelogo)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.ModuleName'),JSON_VALUE(@JsonObjectdata, '$.ModuleEmail'),JSON_VALUE(@JsonObjectdata, '$.PhoneId'),JSON_VALUE(@JsonObjectdata, '$.ModulePhone'),JSON_VALUE(@JsonObjectdata, '$.ModuleLogo'))

		Set @RespMsg ='Module Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Systemmodules 
		SET Modulename=JSON_VALUE(@JsonObjectdata, '$.ModuleName'),Moduleemail=JSON_VALUE(@JsonObjectdata, '$.ModuleEmail'),
		PhoneId=JSON_VALUE(@JsonObjectdata, '$.PhoneId'),Modulephone=JSON_VALUE(@JsonObjectdata, '$.ModulePhone'),Modulelogo=JSON_VALUE(@JsonObjectdata, '$.ModuleLogo') WHERE ModuleId =JSON_VALUE(@JsonObjectdata, '$.ModuleId')

		Set @RespMsg ='Module Updated Successfully.'
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