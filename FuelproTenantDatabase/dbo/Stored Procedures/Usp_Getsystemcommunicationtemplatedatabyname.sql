CREATE PROCEDURE [dbo].[Usp_Getsystemcommunicationtemplatedatabyname]
@Isemail BIT,
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
		  SELECT TOP 1 a.Templateid,a.Templatename,a.Templatesubject,a.Templatebody,a.Isactive,a.Isdeleted,a.Isemailsms
		  FROM Communicationtemplates a
		  WHERE a.Templatename=@Templatename AND a.Isactive=1 AND a.Isdeleted=0 AND a.Isemailsms=@Isemail
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