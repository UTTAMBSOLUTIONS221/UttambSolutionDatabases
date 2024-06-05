CREATE PROCEDURE [dbo].[Usp_Getsystemfortysevennewsblogdata]
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
			SELECT a.Systemblogid,a.Systemblogtitle,a.Systemblogdescription,a.Systemblogcategoryid,b.BlogCategoryName,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Createdby,c.Firstname+' '+ c.lastName as Createdbyname,a.Modifiedby,d.Firstname+' '+ d.lastName as Modifiedbyname,a.Datemodified,a.Datecreated,a.Systemblogstatus,a.Isactive,a.Isdeleted
			FROM Fortysevennewsblogs a
			INNER JOIN BlogCategory b ON a.Systemblogcategoryid=b.BlogCategoryId
			INNER JOIN Systemstaffs c ON a.Createdby=c.Staffid
			INNER JOIN Systemstaffs d ON a.Modifiedby=d.Staffid
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