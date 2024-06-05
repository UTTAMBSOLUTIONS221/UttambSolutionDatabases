CREATE PROCEDURE [dbo].[Usp_RegisterSystemStaffRole]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.RoleId')=0)
		BEGIN
		INSERT INTO Systemroles(Rolename, Roledescription)
			SELECT
				JSON_VALUE(@JsonObjectdata, '$.Rolename'),
				JSON_VALUE(@JsonObjectdata, '$.Roledescription')

			INSERT INTO Systemroleperms(RoleId,PermissionId)
			SELECT SCOPE_IDENTITY(), p.PermissionId FROM OPENJSON(@JsonObjectdata, '$.Permissions') WITH ( PermissionId BIGINT '$.PermissionId' ) AS p

		Set @RespMsg ='Role Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		 DELETE  FROM Tenantroleperms WHERE RoleId=JSON_VALUE(@JsonObjectdata, '$.RoleId')
		 UPDATE  Tenantroles SET Rolename=JSON_VALUE(@JsonObjectdata, '$.Rolename'), Roledescription= JSON_VALUE(@JsonObjectdata, '$.Roledescription'), Modifiedby= JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified =CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2) WHERE Roleid =JSON_VALUE(@JsonObjectdata, '$.RoleId')
		--IF NOT EXISTS(SELECT * FROM Tenantroleperms WHERE RoleId=JSON_VALUE(@JsonEntity, '$.RoleId'))
		INSERT INTO Tenantroleperms(RoleId,PermissionId)
        SELECT JSON_VALUE(@JsonObjectdata, '$.RoleId'), p.PermissionId FROM OPENJSON(@JsonObjectdata, '$.Permissions') WITH ( PermissionId BIGINT '$.PermissionId' ) AS p
		
		Set @RespMsg ='Role Updated Successfully.'
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