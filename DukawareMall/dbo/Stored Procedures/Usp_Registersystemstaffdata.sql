CREATE PROCEDURE [dbo].[Usp_Registersystemstaffdata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = '',
			@RoleId bigint = 0,
			@ModuleId bigint = 0,
			@ModuleName VARCHAR(100),
			@Shopcode VARCHAR(100),
			@PhoneId bigint,
			@CountryId bigint,
			@RegionId bigint,
			@Phonenumber varchar(15),
			@RegionAreaId bigint,
			@StaffId bigint;

			BEGIN
	
		BEGIN TRY	
		--Validate
		SELECT TOP 1 @CountryId =a.CountryId,@RegionId=b.RegionId,@RegionAreaId=RegionAreaId FROM SystemCountry a 
		INNER JOIN SystemCountryRegions b ON a.CountryId=b.CountryId
		INNER JOIN SystemCountryRegionsAreas c ON b.RegionId=c.RegionId

		IF(JSON_VALUE(@JsonObjectdata, '$.Roleid')=0 )
		BEGIN
			IF NOT EXISTS(SELECT RoleId FROM SystemRoles WHERE Rolename=JSON_VALUE(@JsonObjectdata, '$.Rolename'))
			BEGIN
				INSERT INTO SystemRoles(Rolename,RoleDescription,Isdefault)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Rolename'),JSON_VALUE(@JsonObjectdata, '$.Rolename'),1)
				SET @RoleId= SCOPE_IDENTITY();
			END
			ELSE
			BEGIN
			 SET @RoleId= (SELECT RoleId FROM SystemRoles WHERE Rolename=JSON_VALUE(@JsonObjectdata, '$.Rolename'));
			END
		END
		ELSE
		BEGIN
			SET @RoleId= JSON_VALUE(@JsonObjectdata, '$.Roleid');
		END

		IF(JSON_VALUE(@JsonObjectdata, '$.Phoneid')=0)
		BEGIN
		 SET @PhoneId= (SELECT  PhoneId FROM SystemPhonecodes WHERE SUBSTRING(Codename, 2, 3) =SUBSTRING(JSON_VALUE(@JsonObjectdata, '$.Phonenumber'), 1, 3));
		  SET @Phonenumber=(SELECT SUBSTRING(JSON_VALUE(@JsonObjectdata, '$.Phonenumber'), 4, 9));
		END
		ELSE
		BEGIN
		SET @PhoneId=JSON_VALUE(@JsonObjectdata, '$.Phoneid');
		SET @Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber');
		END
		IF(JSON_VALUE(@JsonObjectdata, '$.StaffId')=0)
		BEGIN
			IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Username=JSON_VALUE(@JsonObjectdata, '$.Username'))
			Begin
				Select  1 as RespStatus, 'Username Address Exists!' as RespMessage
				Return
			End
			IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Phonenumber=@Phonenumber)
			Begin
				Select  1 as RespStatus, 'Phonenumber Exists!' as RespMessage
				Return
			End
		END

		IF(JSON_VALUE(@JsonObjectdata, '$.Module') IS NOT NULL) 
		BEGIN
			IF EXISTS(SELECT ModuleId FROM Systemmodules WHERE Modulename=JSON_VALUE(@JsonObjectdata, '$.Module'))
			BEGIN
				SET @ModuleId= (SELECT ModuleId FROM Systemmodules WHERE Modulename=JSON_VALUE(@JsonObjectdata, '$.Module'));
			END
			ELSE
			BEGIN
			  SET @ModuleId= (SELECT TOP 1 ModuleId FROM Systemmodules);
			END
			SET @ModuleName= JSON_VALUE(@JsonObjectdata, '$.Module');
		END
		ELSE
		BEGIN
		SET @ModuleName= (SELECT TOP 1 Modulename FROM Systemmodules);
		 SET @ModuleId= (SELECT TOP 1 ModuleId FROM Systemmodules);
		END

		
		

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.StaffId')=0)
		BEGIN
		INSERT INTO Systemstaffs(Firstname,Lastname,Emailaddress,Username,Roleid,Phoneid,Phonenumber,CountryId,RegionId,RegionAreaId,Dob,Gender,IDNumber,Passwords,passwordharsh,IsActive,IsDeleted,
		IsDefault,Isstaff,Isshop,Iscustomer,Changepassword,Passwordchangedate,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,moduleId,ParentId,LoginStatus,Createdby,Modifiedby,Datecreated,Datemodified)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Firstname'),JSON_VALUE(@JsonObjectdata, '$.Lastname'),JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),JSON_VALUE(@JsonObjectdata, '$.Username'),@RoleId,
		@PhoneId,@Phonenumber,@CountryId,@RegionId,@RegionAreaId,GETDATE(),JSON_VALUE(@JsonObjectdata, '$.Gender'),JSON_VALUE(@JsonObjectdata, '$.IDNumber'),
		JSON_VALUE(@JsonObjectdata, '$.Passwords'),JSON_VALUE(@JsonObjectdata, '$.passwordharsh'),1,0,0,JSON_VALUE(@JsonObjectdata, '$.Isstaff'),JSON_VALUE(@JsonObjectdata, '$.Isshop'),JSON_VALUE(@JsonObjectdata, '$.Iscustomer'),1,GETDATE(),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),
		JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		JSON_VALUE(@JsonObjectdata, '$.Extra9'),@ModuleId,0,2,JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2))

		SET  @StaffId= SCOPE_IDENTITY();

		IF(JSON_VALUE(@JsonObjectdata, '$.Isshop')='true')
		BEGIN
		Select @Shopcode = dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID)
		 INSERT INTO Systemshops(Displayname,Shopnumber,Shopcode,StaffId,Phoneid,Phonenumber,Emailaddress,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,IsDefault,Isactive,Isdeleted,Datecreated)
		 (SELECT @Shopcode+'-Shop',@Shopcode,@Shopcode,@StaffId,@PhoneId,@Phonenumber,JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),
		JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		JSON_VALUE(@JsonObjectdata, '$.Extra9'),0,1,0,CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))
		END

		Set @RespMsg ='Data Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		UPDATE Systemstaffs 
		SET Firstname=JSON_VALUE(@JsonObjectdata, '$.Firstname'),Lastname=JSON_VALUE(@JsonObjectdata, '$.Lastname'),Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),Username=JSON_VALUE(@JsonObjectdata, '$.Username'),Roleid=@RoleId,
		Phoneid=@PhoneId,Phonenumber=@Phonenumber,Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE StaffId =JSON_VALUE(@JsonObjectdata, '$.StaffId')

		Set @RespMsg ='Data Updated Successfully.'
		Set @RespStat =0; 
		END
		
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,'Insert' AS Data1,@StaffId AS Data2,(JSON_VALUE(@JsonObjectdata, '$.Firstname') +' '+ JSON_VALUE(@JsonObjectdata, '$.Lastname')) AS Data3,JSON_VALUE(@JsonObjectdata, '$.Emailaddress') As Data4, JSON_VALUE(@JsonObjectdata, '$.Passwords') AS Data5,JSON_VALUE(@JsonObjectdata, '$.passwordharsh') AS Data6,JSON_VALUE(@JsonObjectdata, '$.Username')AS Data7,@ModuleName AS Data8,JSON_VALUE(@JsonObjectdata, '$.Action')AS Data9;

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