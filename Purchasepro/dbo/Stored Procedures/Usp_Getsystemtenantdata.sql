CREATE PROCEDURE [dbo].[Usp_Getsystemtenantdata]
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
			SELECT a.Tenantid,a.Tenantname, CASE WHEN a.Tenantlogo IS NULL THEN 'https://www.lenarjisse.com/images/no-image.png' ELSE a.Tenantlogo END AS Tenantlogo,a.Emailserver,a.Emailpassword,Consumerkey,Shortcode,Consumersecret,a.Tenantstatus,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,
			a.Isactive,a.Isdeleted,a.Createdby,a.Modifiedby,b.Firstname +' '+ b.Lastname  AS Createdbyname, c.Firstname +' '+ c.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated FROM Systemtenants a INNER JOIN Systemstaffs b ON a.Createdby=b.StaffId INNER JOIN Systemstaffs c ON a.Modifiedby=c.StaffId
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