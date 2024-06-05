CREATE PROCEDURE [dbo].[Usp_GetSystemRoleDetailData]
    @RoleId BIGINT,
	@Roledetaildata NVARCHAR(MAX) OUTPUT
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
	  
       SET @Roledetaildata= (SELECT  aa.RoleId,aa.Rolename,aa.RoleDescription,aa.Isdefault,
	   (
		   SELECT 
		       a.PermissionId,b.Permissionname,b.Isactive,b.Isdeleted,b.Module 
		   FROM Systemroleperms a 
		   INNER JOIN SystemPermissions b ON a.PermissionId = b.PermissionId WHERE a.RoleId= aa.RoleId
		   FOR JSON PATH
	   ) AS Permissions
       FROM Systemroles aa WHERE  aa.RoleId= @RoleId
	   FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
	   )
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@Roledetaildata AS Roledetaildata;

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