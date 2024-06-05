CREATE PROCEDURE [dbo].[Usp_GetSystemRoleDetailData]
    @RoleId BIGINT,
	@Roledetaildata VARCHAR(MAX)  OUTPUT
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
		  SET @Roledetaildata = (
			   SELECT a.RoleId,a.Rolename,a.RoleDescription,a.Isdefault,a.IsActive,a.IsDeleted,a.Createdby,a.Modifiedby,a.Datecreated,a.Datemodified,
			   (
					SELECT aa.PermissionId,aa.RoleId,bb.Permissionname,bb.Isadmin 
					FROM Systemroleperms aa
					INNER JOIN Systempermissions bb ON aa.PermissionId=bb.PermissionId
					WHERE a.RoleId= aa.RoleId
				   FOR JSON PATH
			  ) AS Permissions
			   FROM Systemroles a 
			   WHERE a.RoleId=@RoleId
				FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
			  )
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
           SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@Roledetaildata AS Roledetaildata  
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
