CREATE PROCEDURE [dbo].[Usp_RegisterSystemStaffData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@UserId BIGINT,
			@Data1 varchar(250) = '',
			@Data2 varchar(250) = '',
			@Data3 varchar(250) = '',
			@Data4 varchar(250) = '',
			@Data5 varchar(250) = '',
			@Data6 varchar(250) = '',
			@Data7 varchar(250) = '',
			@Data8 varchar(250) = '',
			@Data9 varchar(250) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.Userid')=0)
		BEGIN
			IF EXISTS(SELECT Userid FROM SystemStaffs WHERE Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.Tenantid'))
			BEGIN
				Select  1 as RespStatus, 'Similar Email Address exists!. Contact Admin!' as RespMessage;
				Return
			END
			IF EXISTS(SELECT Userid FROM SystemStaffs WHERE Username=JSON_VALUE(@JsonObjectdata, '$.Username') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.Tenantid'))
			BEGIN
				Select  1 as RespStatus, 'Similar username exists!. Contact Admin!' as RespMessage;
				Return
			END
			IF EXISTS(SELECT Userid FROM SystemStaffs WHERE Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.Tenantid'))
			BEGIN
				Select  1 as RespStatus, 'Similar Phonenumber exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.Userid')>0)
		BEGIN
		  UPDATE SystemStaffs SET Firstname=JSON_VALUE(@JsonObjectdata, '$.Firstname'),Lastname=JSON_VALUE(@JsonObjectdata, '$.Lastname'),Phoneid=JSON_VALUE(@JsonObjectdata, '$.Phoneid'),Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),Username=JSON_VALUE(@JsonObjectdata, '$.Username'),Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),Roleid=JSON_VALUE(@JsonObjectdata, '$.Roleid'),LimitTypeId=JSON_VALUE(@JsonObjectdata, '$.LimitTypeId'),LimitTypeValue=JSON_VALUE(@JsonObjectdata, '$.LimitTypeValue'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified =JSON_VALUE(@JsonObjectdata, '$.Datemodified') WHERE Userid=JSON_VALUE(@JsonObjectdata, '$.Userid')

		  DELETE FROM LnkStaffStation WHERE UserId = JSON_VALUE(@JsonObjectdata, '$.Userid') AND StationId NOT IN (SELECT StationId FROM OPENJSON(@JsonObjectdata, '$.SystemStation') WITH (StationId INT '$.StationId'));

		  INSERT INTO LnkStaffStation (UserId, StationId)
		  SELECT JSON_VALUE(@JsonObjectdata, '$.Userid'), ss.StationId FROM OPENJSON(@JsonObjectdata, '$.SystemStation') WITH (StationId BIGINT) AS ss
          WHERE NOT EXISTS (SELECT lss.StationId FROM LnkStaffStation lss WHERE lss.UserId = JSON_VALUE(@JsonObjectdata, '$.Userid'));

		  SELECT @Data1 = a.Userid,@Data2=a.Firstname +' '+ a.Lastname,@Data4=Passwords,@Data5=Passharsh,@Data6=Username,@Data7=Emailaddress, @Data8='Update',@Data9=(SELECT StationId FROM LnkStaffStation WHERE UserId = JSON_VALUE(@JsonObjectdata, '$.Userid') FOR JSON PATH) FROM SystemStaffs a WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.Userid')
		END
		ELSE
		BEGIN
		INSERT INTO SystemStaffs(Tenantid,Firstname,Lastname,Phoneid,Phonenumber,Username,Emailaddress,Roleid,Passharsh,Passwords,LimitTypeId,LimitTypeValue,Isactive,Isdeleted,Loginstatus,Passwordresetdate,Createdby,Modifiedby,Lastlogin,Datemodified,Datecreated)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.Tenantid'),JSON_VALUE(@JsonObjectdata, '$.Firstname'),JSON_VALUE(@JsonObjectdata, '$.Lastname'),
		JSON_VALUE(@JsonObjectdata, '$.Phoneid'),JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),JSON_VALUE(@JsonObjectdata, '$.Username'),
		JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),JSON_VALUE(@JsonObjectdata, '$.Roleid'),JSON_VALUE(@JsonObjectdata, '$.Passharsh'),JSON_VALUE(@JsonObjectdata, '$.Passwords'),
		JSON_VALUE(@JsonObjectdata, '$.LimitTypeId'),JSON_VALUE(@JsonObjectdata, '$.LimitTypeValue'),1,0,2,CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),
		JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated')  AS datetime2))
		
		SET @UserId = SCOPE_IDENTITY();

		INSERT INTO LnkStaffStation(UserId,StationId)
		SELECT @UserId, StationId FROM OPENJSON (@JsonObjectdata, '$.SystemStation') WITH (StationId BIGINT)

		 SELECT @Data1 = a.Userid,@Data2=a.Firstname +' '+ a.Lastname,@Data4=Passwords,@Data5=Passharsh,@Data6=Username,@Data7=Emailaddress, @Data8='Insert',@Data9=(SELECT StationId FROM LnkStaffStation WHERE UserId = @UserId FOR JSON PATH) FROM SystemStaffs a WHERE a.Userid=@UserId
		END
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		  Select @RespStat as RespStatus, @RespMsg as RespMessage,@Data1 AS Data1,@Data2 AS Data2, JSON_VALUE(@JsonObjectdata, '$.SystemStation[0].StationId') AS Data3,@Data4 AS Data4,@Data5 AS Data5,@Data6 AS Data6,@Data7 AS Data7,@Data8 AS Data8,@Data9 AS Data9;
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
