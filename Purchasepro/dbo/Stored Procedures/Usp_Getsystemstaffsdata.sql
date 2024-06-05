﻿CREATE PROCEDURE [dbo].[Usp_Getsystemstaffsdata]
@TenantId BIGINT
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
			 SELECT a.Staffid,b.Tenantname,C.RoleName,a.Firstname+' '+a.Lastname AS Staffname,a.Emailaddress,a.Roleid,a.Phoneid,d.codename+''+ a.Phonenumber AS Phonenumber,a.Dob,a.Gender,
			 a.IDNumber,a.Passwords,a.passwordharsh,a.IsActive,a.IsDeleted,a.IsDefault,a.Isstaff,a.Changepassword,a.Passwordchangedate,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,
			 a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.ParentId,a.LoginStatus,a.Createdby,a.Modifiedby,a.Datecreated,a.Datemodified
		  FROM Systemstaffs a 
		  INNER JOIN Systemtenants b ON a.Tenantid=b.Tenantid
		  INNER JOIN SystemRoles c ON a.RoleId=c.RoleId
		  INNER JOIN Systemphonecodes d ON a.Phoneid=d.PhoneId
		  WHERE a.Tenantid = @TenantId
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