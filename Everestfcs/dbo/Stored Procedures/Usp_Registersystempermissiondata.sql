CREATE PROCEDURE [dbo].[Usp_Registersystempermissiondata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = '',
			@PermissionId BIGINT;
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.PermissionId')=0)
		BEGIN
		INSERT INTO Systempermissions(Permissionname,Isactive,Isdeleted,Module,Isadmin)
	    SELECT JSON_VALUE(@JsonObjectdata, '$.Permissionname'),1,0,1,JSON_VALUE(@JsonObjectdata, '$.Isadmin')
		SET @PermissionId =SCOPE_IDENTITY();
		IF(JSON_VALUE(@JsonObjectdata, '$.Isadmin')='true')
		BEGIN
			INSERT INTO Systemroleperms
			SELECT (SELECT Roleid FROM SystemRoles WHERE Rolename='Systemsuperadmin'),@PermissionId
		END
		ELSE
		BEGIN
		    INSERT INTO Systemroleperms
			SELECT (SELECT Roleid FROM SystemRoles WHERE Rolename='Systemsuperadmin'),@PermissionId

		    INSERT INTO Systemroleperms
			SELECT (SELECT Roleid FROM SystemRoles WHERE Rolename='System Super Admin'),@PermissionId
		END
		Set @RespMsg ='Permission Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		 UPDATE  Systempermissions SET Permissionname=JSON_VALUE(@JsonObjectdata, '$.Permissionname'), Isadmin= JSON_VALUE(@JsonObjectdata, '$.Isadmin') WHERE PermissionId =JSON_VALUE(@JsonObjectdata, '$.PermissionId')
		Set @RespMsg ='Permission Updated Successfully.'
		Set @RespStat =0; 
		END
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage;

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