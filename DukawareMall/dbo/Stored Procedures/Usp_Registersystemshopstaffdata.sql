CREATE PROCEDURE [dbo].[Usp_Registersystemshopstaffdata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = '',
			@ShopId bigint,
			@StaffId bigint;

			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.StaffId')=0)
		BEGIN
			IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress'))
			Begin
				Select  1 as RespStatus, 'Email Address Exists!' as RespMessage
				Return
			End
			IF EXISTS(SELECT StaffId FROM systemstaffs WHERE Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber'))
			Begin
				Select  1 as RespStatus, 'Phonenumber Exists!' as RespMessage
				Return
			End
		END

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.StaffId')=0)
		BEGIN
		INSERT INTO Systemshops(Displayname,Isactive,Isdeleted,Datecreated)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Displayname'),1,0,CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))
		SET @ShopId = SCOPE_IDENTITY();

		INSERT INTO Systemstaffs(Firstname,Lastname,Emailaddress,Roleid,Phoneid,Phonenumber,Dob,Gender,IDNumber,Passwords,passwordharsh,CountryId,IsActive,IsDeleted,
		IsDefault,Isstaff,Changepassword,Passwordchangedate,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,ParentId,LoginStatus,Createdby,Modifiedby,Datecreated,Datemodified)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.Firstname'),JSON_VALUE(@JsonObjectdata, '$.Lastname'),JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),JSON_VALUE(@JsonObjectdata, '$.Roleid'),
		JSON_VALUE(@JsonObjectdata, '$.Phoneid'),JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),GETDATE(),JSON_VALUE(@JsonObjectdata, '$.Gender'),JSON_VALUE(@JsonObjectdata, '$.IDNumber'),
		JSON_VALUE(@JsonObjectdata, '$.Passwords'),JSON_VALUE(@JsonObjectdata, '$.passwordharsh'),(SELECT TOP 1 Countryid FROM SystemCountry),1,0,0,1,1,GETDATE(),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),
		JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		JSON_VALUE(@JsonObjectdata, '$.Extra9'),@ShopId,2,JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2))

		SET  @StaffId= SCOPE_IDENTITY();
		Set @RespMsg ='Shop and Staff Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		UPDATE Systemshops SET Displayname= JSON_VALUE(@JsonObjectdata, '$.Displayname') WHERE ShopId= JSON_VALUE(@JsonObjectdata, '$.ShopId')
		
		UPDATE Systemstaffs 
		SET Firstname=JSON_VALUE(@JsonObjectdata, '$.Firstname'),Lastname=JSON_VALUE(@JsonObjectdata, '$.Lastname'),Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),Roleid=JSON_VALUE(@JsonObjectdata, '$.Roleid'),
		Phoneid=JSON_VALUE(@JsonObjectdata, '$.Phoneid'),Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE StaffId =JSON_VALUE(@JsonObjectdata, '$.StaffId')

		Set @RespMsg ='Shop and Staff Updated Successfully.'
		Set @RespStat =0; 
		END
		
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,'Insert' AS Data1,@StaffId AS Data2,(JSON_VALUE(@JsonObjectdata, '$.Firstname') +' '+ JSON_VALUE(@JsonObjectdata, '$.Lastname')) AS Data3,JSON_VALUE(@JsonObjectdata, '$.Emailaddress') As Data4, JSON_VALUE(@JsonObjectdata, '$.Passwords') AS Data5,JSON_VALUE(@JsonObjectdata, '$.passwordharsh') AS Data6;

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