
CREATE PROCEDURE [dbo].[Usp_Verifysystemstaffs]
	@Username varchar(100),
    @StaffDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'login success';
			BEGIN
				--validate	
				IF NOT EXISTS(SELECT StaffId FROM systemstaffs WHERE Emailaddress=@Username)
				Begin
					--Select  1 as RespStatus, 'Invalid Emailaddress or User does not Exist!' as RespMessage,@StaffDetails AS StaffDetails
					SET @StaffDetails = (SELECT 1 as RespStatus, 'Invalid Emailaddress or User does not Exist!' as RespMessage,@StaffDetails AS StaffDetails FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
					Return
				End

				IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Emailaddress=@Username AND IsActive=0)
				Begin
					SET @StaffDetails = (Select  1 as RespStatus, 'Inactive Account Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
					Return
				End
				IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Emailaddress=@Username AND IsDeleted=1)
				Begin
					SET @StaffDetails = (Select  1 as RespStatus, 'Account Deleted Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
					Return
				End
				IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Emailaddress=@Username AND LoginStatus=3)
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
								SELECT
									a.Staffid,
									a.Tenantid,
									b.Tenantname,
									ISNULL(b.Tenantlogo,null) AS Tenantlogo,
									b.Emailserver,
									b.Emailpassword,
									b.Shortcode,
									b.Tenantstatus,
									a.Firstname + ' ' + a.Lastname AS Fullname,
									d.Codename + '' + a.Phonenumber AS Phonenumber,
									a.Emailaddress,
									a.Roleid,
									c.Rolename,
									a.Passwordharsh AS Passharsh,
									a.Passwords,
									a.Isactive,
									a.Isdeleted,
									a.Loginstatus,
									a.Changepassword,
									a.Passwordchangedate AS Passwordresetdate,
									a.ParentId AS Parentid,
									a.Createdby,
									a.Modifiedby,
									a.Datemodified,
									a.Datecreated,
									(
										SELECT
											bb.PermissionId,
											bb.Permissionname,
											bb.Isactive,
											bb.Isdeleted,
											bb.Module,
											bb.Isadmin
										FROM Systemroleperms aa
										INNER JOIN Systempermissions bb ON aa.PermissionId = bb.PermissionId
										WHERE a.RoleId = aa.Roleid
										FOR JSON PATH
									) AS Permission
								FROM systemstaffs a
								INNER JOIN Systemtenants b ON b.Tenantid = a.Tenantid
								INNER JOIN Systemroles c ON c.Roleid = a.Roleid
								INNER JOIN SystemPhoneCodes d ON a.Phoneid = d.Phoneid
								WHERE a.Emailaddress = @Username
							FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
							) AS Usermodel
						FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
					);
			END
		END
END
