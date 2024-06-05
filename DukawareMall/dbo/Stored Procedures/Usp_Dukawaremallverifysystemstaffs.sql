CREATE PROCEDURE [dbo].[Usp_Dukawaremallverifysystemstaffs]
	@Username varchar(100),
    @StaffDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(550) = 'Dear '+(SELECT Firstname+' '+Lastname FROM systemstaffs WHERE Username=@Username)+', You registered as a Regional Sales Representative for DUKAWARE MALL and by this you need to verify your account by Ksh. 300 to this Till No. 5474591 and Share the Mpesa message to email. 
		Once your account is verified you will recieve a call or directions from the person who will be your imediate supervisor and he will guide you accordingly. 
		Feel free to reach us through our social handles';
			BEGIN
	
		BEGIN TRY
		--validate	
		IF NOT EXISTS(SELECT StaffId FROM systemstaffs WHERE Username=@Username)
		Begin
		    --Select  1 as RespStatus, 'Invalid Emailaddress or User does not Exist!' as RespMessage,@StaffDetails AS StaffDetails
		    SELECT 1 as RespStatus, 'Invalid Emailaddress or User does not Exist!' as RespMessage,@StaffDetails AS StaffDetails;
			Return
		End

		IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Username=@Username AND IsActive=0)
		Begin
			Select  1 as RespStatus, 'Inactive Account Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails;
			Return
		End
		IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Username=@Username AND IsDeleted=1)
		Begin
			Select  1 as RespStatus, 'Account Deleted Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails;
			Return
		End
		IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Username=@Username AND LoginStatus=3)
		Begin
			Select  1 as RespStatus, 'Account Blocked Contact Admin!' as RespMessage,@StaffDetails AS StaffDetails;
			Return
		End
		
		BEGIN TRANSACTION;
	 	 SET @StaffDetails = (
		 	SELECT @RespStat as RespStatus, @RespMsg as RespMessage,a.StaffId, (CASE WHEN  a.Isshop =1 THEN (SELECT TOP 1 ShopId  FROM Systemshops WHERE StaffId=a.StaffId) ELSE a.StaffId END) AS ShopId, (CASE WHEN  a.Isshop =1 THEN (SELECT TOP 1 Displayname  FROM Systemshops WHERE StaffId=a.StaffId) ELSE a.Firstname+' '+a.Lastname END) AS Displayname,a.Firstname+' '+a.Lastname AS Fullname,d.Codename+''+a.Phonenumber AS Phonenumber,a.Emailaddress,a.Roleid,c.Rolename,a.passwordharsh AS Passharsh,a.Passwords,a.Isactive,a.Isdeleted,a.Isshop,a.Isstaff,a.Iscustomer,
			a.Loginstatus,a.Changepassword,a.Passwordchangedate AS Passwordresetdate,e.ModuleId,a.ParentId,a.Createdby,a.Modifiedby,a.Datemodified,a.Datecreated,e.Modulename,e.Moduleemail,f.Codename+''+e.Modulephone AS Modulephone,e.Modulelogo,
			(
			    SELECT bb.PermissionId,bb.Permissionname,bb.Isactive,bb.Isdeleted,bb.Module
                FROM Systemroleperms aa 
				INNER JOIN Systempermissions bb ON aa.PermissionId=bb.PermissionId
				  WHERE a.RoleId=aa.Roleid
				 FOR JSON PATH
			) 
			AS Permission
			FROM systemstaffs a
		    INNER JOIN Systemroles c ON c.Roleid=a.Roleid
			INNER JOIN SystemPhoneCodes d ON a.Phoneid=d.Phoneid
			LEFT JOIN Systemmodules e ON a.ModuleId=e.ModuleId
			LEFT JOIN SystemPhoneCodes f ON e.Phoneid=f.Phoneid
			WHERE a.Username=@Username
	        FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
			);

		Set @RespMsg =@RespMsg;
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		 SELECT @RespStat as RespStatus, @RespMsg as RespMessage,@StaffDetails AS StaffDetails;
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