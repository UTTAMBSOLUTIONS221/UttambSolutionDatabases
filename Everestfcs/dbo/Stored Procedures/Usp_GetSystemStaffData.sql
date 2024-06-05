CREATE PROCEDURE [dbo].[Usp_GetSystemStaffData]
@TenantId BIGINT,
@Offset INT,
@Count INT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	
		
		BEGIN TRANSACTION;
	       SELECT a.Userid,a.Firstname,a.Lastname,a.Emailaddress AS Email,c.Codename + '' +a.Phonenumber AS Phone,'' AS Pin,'' AS PinHarsh,a.RoleId,b.Rolename,a.LoginStatus,
				  GETDATE() AS Lastlogin,GETDATE() AS Passwordchange,0 AS IsDefault,0 AS PortalAccess,a.IsActive,a.IsDeleted,a.Createdby,a.Modifiedby,a.Datecreated,a.Datemodified
           FROM Systemstaffs a
		   INNER JOIN Systemroles b ON b.RoleId=a.RoleId
		   INNER JOIN SystemPhoneCodes c ON a.Phoneid = c.Phoneid
		   WHERE a.TenantId=@TenantId
		   --INNER JOIN ConsumLimitType c ON a.LimitTypeId=c.LimitTypeId
		   ORDER BY a.Datecreated
		OFFSET @Offset ROWS
		FETCH NEXT @Count ROWS ONLY;

	    Set @RespMsg ='Success'
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
