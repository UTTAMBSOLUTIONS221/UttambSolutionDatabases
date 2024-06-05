CREATE PROCEDURE [dbo].[Usp_Registersystempermissiondata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.PermissionId')=0)
		BEGIN
		INSERT INTO Systempermissions(Permissionname,Isactive,Isdeleted,Module,Isadmin)
	    SELECT JSON_VALUE(@JsonObjectdata, '$.Permissionname'),1,0,1,JSON_VALUE(@JsonObjectdata, '$.Isadmin')
		INSERT INTO Systemroleperms
		SELECT (SELECT Roleid FROM SystemRoles WHERE Rolename='Systemsuperadmin'),SCOPE_IDENTITY()
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
