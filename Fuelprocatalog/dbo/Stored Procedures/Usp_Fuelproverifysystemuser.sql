
CREATE PROCEDURE [dbo].[Usp_Fuelproverifysystemuser]
	@Username varchar(100),
    @StaffDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'login success';
			BEGIN
				--validate	
				IF NOT EXISTS(SELECT Userid FROM Tenantusers WHERE Username=@Username)
				Begin
					--Select  1 as RespStatus, 'Invalid Emailaddress or User does not Exist!' as RespMessage,@StaffDetails AS StaffDetails
					SET @StaffDetails = (SELECT 1 as RespStatus, 'Invalid Emailaddress or User does not Exist!' as RespMessage,@StaffDetails AS StaffDetails FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
					Return
				End

				IF EXISTS(SELECT Userid FROM Tenantusers WHERE Username=@Username AND IsActive=0)
				Begin
					SET @StaffDetails = (Select  1 as RespStatus, 'Inactive Account Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
					Return
				End
				IF EXISTS(SELECT Userid FROM Tenantusers WHERE Username=@Username AND IsDeleted=1)
				Begin
					SET @StaffDetails = (Select  1 as RespStatus, 'Account Deleted Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
					Return
				End
				IF EXISTS(SELECT Userid FROM Tenantusers WHERE Username=@Username AND LoginStatus=3)
				Begin
					SET @StaffDetails = (Select  1 as RespStatus, 'Account Blocked Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
					Return
				End
		
			BEGIN 
					SET @StaffDetails = (
						SELECT
							@RespStat AS RespStatus,
							@RespMsg AS RespMessage,
							(
								SELECT a.Userid,a.Tenantid,b.Tenantname,b.Tenantkey,b.Tenantkrapin,b.Emailaddress AS TenantEmailaddress,b.Connectionstring,b.Tenantsubdomain,b.Tenantemailkey,b.Tenantemailpassword, a.Firstname + ' ' + a.Lastname AS Fullname,d.Codename + '' + a.Phonenumber AS Phonenumber,
                                      a.Username,a.Emailaddress,a.Roleid,c.Rolename,a.Passharsh,a.Passwords,a.LimitTypeId,a.LimitTypeValue,a.Isactive,a.Isdeleted,a.Loginstatus,a.Passwordresetdate,a.Createdby,a.Modifiedby,a.Lastlogin,a.Datemodified,a.Datecreated,
									(
										SELECT 
										    bb.PermissionId,
											bb.Permissionname,
											bb.Isactive,
											bb.Isdeleted,
											bb.Module,
											bb.Isadmin
											FROM Tenantroleperms aa
											INNER JOIN Tenantpermissions bb ON aa.PermissionId=bb.PermissionId
										WHERE a.RoleId = aa.Roleid
										FOR JSON PATH
									) AS Permission
								FROM Tenantusers a
								INNER JOIN Tenantaccounts b ON b.Tenantid = a.Tenantid
								INNER JOIN Tenantroles c ON c.Roleid = a.Roleid
								INNER JOIN SystemPhoneCodes d ON a.Phoneid = d.Phoneid
								WHERE a.Username = @Username
							FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
							) AS Usermodel
						FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
					);
			END
		END
END