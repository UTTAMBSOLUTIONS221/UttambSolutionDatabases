CREATE PROCEDURE [dbo].[Usp_Getsystemcommunicationtemplatedatabynameandmodule]
@Moduledata VARCHAR(100),
@Templatename VARCHAR(100)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		
		BEGIN TRANSACTION;
		  SELECT TOP 1 a.Templateid,a.Templatename,a.Templatesubject,a.Templatebody,b.ModuleName AS Module,b.Moduleemail,c.codename+''+ b.Modulephone AS Modulephone,b.Modulelogo,a.Isactive,a.Isdeleted
		  FROM Communicationtemplates a
		  INNER JOIN Systemmodules b ON a.ModuleId=b.ModuleId
		  INNER JOIN SystemPhoneCodes c ON b.PhoneId=c.Phoneid
		  WHERE (''=b.ModuleName OR b.ModuleName = @Moduledata) AND a.Templatename=@Templatename AND a.Isactive=1 AND a.Isdeleted=0 
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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