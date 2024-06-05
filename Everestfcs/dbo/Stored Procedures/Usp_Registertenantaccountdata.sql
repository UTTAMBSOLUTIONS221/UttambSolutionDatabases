CREATE PROCEDURE [dbo].[Usp_Registertenantaccountdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@TenantId BIGINT,
			@StationId BIGINT,
			@RoleId BIGINT,
			@StaffId BIGINT,
			@TenantLogopath VARCHAR(200);
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.Tenantid')>0)
		BEGIN
			IF(JSON_VALUE(@JsonObjectdata, '$.TenantLogo') IS NULL)
			BEGIN
			  SET @TenantLogopath=(SELECT TOP 1 TenantLogo FROM Tenantaccounts WHERE TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'));
			END 
			ELSE
			BEGIN
			 SET @TenantLogopath=JSON_VALUE(@JsonObjectdata, '$.TenantLogo');
			END
		END
		IF(JSON_VALUE(@JsonObjectdata, '$.Tenantid')>0)
		BEGIN
		  UPDATE Tenantaccounts SET   Countryid=JSON_VALUE(@JsonObjectdata, '$.Countryid'),Tenantname=JSON_VALUE(@JsonObjectdata, '$.Tenantname'),Tenantsubdomain=JSON_VALUE(@JsonObjectdata, '$.Tenantsubdomain'),TenantLogo=@TenantLogopath,TenantEmail=JSON_VALUE(@JsonObjectdata, '$.TenantEmail'),Phoneid=JSON_VALUE(@JsonObjectdata, '$.Phoneid'),Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),TenantReference=JSON_VALUE(@JsonObjectdata, '$.TenantReference'),TenantPIN=JSON_VALUE(@JsonObjectdata, '$.TenantPIN'),
		   IsCCEmail=JSON_VALUE(@JsonObjectdata, '$.IsCCEmail'),CCEmail=JSON_VALUE(@JsonObjectdata, '$.CCEmail'),EmailAddress=JSON_VALUE(@JsonObjectdata, '$.EmailAddress'),EmailPassword=JSON_VALUE(@JsonObjectdata, '$.EmailPassword'),
		   Messageusername=JSON_VALUE(@JsonObjectdata, '$.Messageusername'),Messageapikey=JSON_VALUE(@JsonObjectdata, '$.Messageapikey'),ApplyTax=JSON_VALUE(@JsonObjectdata, '$.ApplyTax'),NoOfDecimalPlaces=JSON_VALUE(@JsonObjectdata, '$.NoOfDecimalPlaces'),IsEmailEnabled=JSON_VALUE(@JsonObjectdata, '$.IsEmailEnabled'),
		   IsSmsEnabled=JSON_VALUE(@JsonObjectdata, '$.IsSmsEnabled'),IsTemplateTrancated=JSON_VALUE(@JsonObjectdata, '$.IsTemplateTrancated'),Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),
		   Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		   Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2) WHERE TenantId=JSON_VALUE(@JsonObjectdata, '$.Tenantid')
		END
		ELSE
		BEGIN
			INSERT INTO Tenantaccounts(Countryid,Tenantname,Tenantsubdomain,TenantLogo,TenantEmail,Phoneid,Phonenumber,TenantReference,TenantPIN,IsCCEmail,CCEmail,StaffAutoLogOff,
			EmailAddress,EmailPassword,Messageusername,Messageapikey,ApplyTax,NoOfDecimalPlaces,IsEmailEnabled,IsSmsEnabled,IsTemplateTrancated,Extra,Extra1,
			Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Tenantloginstatus,Isactive,Isdeleted,Createdby,Modifiedby,DateCreated,DateModified)
		   (SELECT JSON_VALUE(@JsonObjectdata, '$.Countryid'),JSON_VALUE(@JsonObjectdata, '$.Tenantname'),JSON_VALUE(@JsonObjectdata, '$.Tenantsubdomain'),JSON_VALUE(@JsonObjectdata, '$.TenantLogo'),JSON_VALUE(@JsonObjectdata, '$.TenantEmail'),JSON_VALUE(@JsonObjectdata, '$.Phoneid'),JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),JSON_VALUE(@JsonObjectdata, '$.TenantReference'),JSON_VALUE(@JsonObjectdata, '$.TenantPIN'),
		   JSON_VALUE(@JsonObjectdata, '$.IsCCEmail'),JSON_VALUE(@JsonObjectdata, '$.CCEmail'),1,JSON_VALUE(@JsonObjectdata, '$.EmailAddress'),JSON_VALUE(@JsonObjectdata, '$.EmailPassword'),
		   JSON_VALUE(@JsonObjectdata, '$.Messageusername'),JSON_VALUE(@JsonObjectdata, '$.Messageapikey'),JSON_VALUE(@JsonObjectdata, '$.ApplyTax'),JSON_VALUE(@JsonObjectdata, '$.NoOfDecimalPlaces'),JSON_VALUE(@JsonObjectdata, '$.IsEmailEnabled'),
		   JSON_VALUE(@JsonObjectdata, '$.IsSmsEnabled'),JSON_VALUE(@JsonObjectdata, '$.IsTemplateTrancated'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),
		   JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		   JSON_VALUE(@JsonObjectdata, '$.Extra9'),JSON_VALUE(@JsonObjectdata, '$.Extra10'),0,1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2))
		   SET @TenantId = SCOPE_IDENTITY();
		   --Insert Stations
			INSERT INTO SystemStations(Tenantid,Sname,Semail,Phoneid,Phone,IsDefault,IsActive,IsDeleted,Createdby,Modifiedby,DateCreated,DateModified)
		    (SELECT @TenantId,'Default Station','info@'+JSON_VALUE(@JsonObjectdata, '$.Tenantsubdomain'),JSON_VALUE(@JsonObjectdata, '$.Phoneid'),JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),1,1,0,0,0,GETDATE(),GETDATE())
		   SET @StationId= SCOPE_IDENTITY();
		 --Insert roles
		   INSERT INTO Systemroles(Rolename,RoleDescription,Tenantid,Isdefault,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
		  (SELECT 'System Super Admin',  JSON_VALUE(@JsonObjectdata, '$.Tenantname')+'System Super Admin',@TenantId,1,1,0,0,0,GETDATE(),GETDATE())
		   SET @RoleId= SCOPE_IDENTITY();
		--Link Role to Permisions
		    INSERT INTO Systemroleperms(RoleId,PermissionId)
			(SELECT @RoleId,PermissionId FROM Systempermissions WHERE Isadmin=0)
		   --Insert default staffs
		  INSERT INTO SystemStaffs(Tenantid,Firstname,Lastname,Phoneid,Phonenumber,Username,Emailaddress,Roleid,Passharsh,Passwords,
		  LimitTypeId,LimitTypeValue,Isactive,Isdeleted,Isdefault,Loginstatus,Passwordresetdate,Parentid,Createdby,Modifiedby,Lastlogin,Datemodified,Datecreated)
		  (SELECT @TenantId,JSON_VALUE(@JsonObjectdata, '$.Tenantname'),'Admin',JSON_VALUE(@JsonObjectdata, '$.Phoneid'),JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),'admin@'+JSON_VALUE(@JsonObjectdata, '$.Tenantsubdomain'),
		  JSON_VALUE(@JsonObjectdata, '$.TenantEmail'),@RoleId,JSON_VALUE(@JsonObjectdata, '$.Passharsh'),JSON_VALUE(@JsonObjectdata, '$.Passwords'),
		  (SELECT LimitTypeId FROM ConsumLimitType WHERE LimitTypename ='Amount'),0,1,0,1,0,GETDATE(),0,0,0,GETDATE(),GETDATE(),GETDATE())
		  SET @StaffId=SCOPE_IDENTITY();
		   --Link Staff to Stations
		   INSERT INTO LnkStaffStation(UserId,StationId)
		   (SELECT @StaffId,@StationId)
		  
		  Set @RespMsg ='Saved Successfully.'
		  Set @RespStat =0; 
		END 

		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage, @StaffId AS Data1;

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