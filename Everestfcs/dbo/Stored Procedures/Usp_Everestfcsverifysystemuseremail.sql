CREATE PROCEDURE [dbo].[Usp_Everestfcsverifysystemuseremail]
	@Username varchar(100),
    @StaffDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'login success';
			BEGIN
	
		BEGIN TRY
		--validate	

		BEGIN TRANSACTION;
	 	 SET @StaffDetails = (
		 	SELECT @RespStat as RespStatus, @RespMsg as RespMessage,a.Userid,a.Tenantid,a.Firstname+' '+a.Lastname AS Fullname,d.Codename+''+a.Phonenumber AS Phonenumber,a.Username,a.Emailaddress,a.Roleid,c.Rolename,a.Passharsh,a.Passwords,a.LimitTypeId,a.LimitTypeValue,a.Isactive,a.Isdeleted,
			a.Loginstatus,a.Passwordresetdate,a.Createdby,a.Modifiedby,a.Lastlogin,a.Datemodified,a.Datecreated,b.Tenantname,b.Tenantsubdomain,
			(
			    SELECT bb.PermissionId,bb.Permissionname,bb.Isactive,bb.Isdeleted,bb.Module
                FROM Systemroleperms aa 
				INNER JOIN Systempermissions bb ON aa.PermissionId=bb.PermissionId
				  WHERE a.RoleId=aa.Roleid
				 FOR JSON PATH
			) 
			AS Permission
			FROM SystemStaffs a
			INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid
		    INNER JOIN Systemroles c ON c.Roleid=a.Roleid
			INNER JOIN SystemPhoneCodes d ON a.Phoneid=d.Phoneid
			 WHERE a.Emailaddress=@Username
	  FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
			);

		Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

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