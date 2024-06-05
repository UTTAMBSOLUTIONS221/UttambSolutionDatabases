CREATE PROCEDURE [dbo].[Usp_GetSystemRolesData]
    @TenantId BIGINT,
	@Offset INT,
	@Count INT
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
	  
       SELECT  RoleId,Rolename,RoleDescription,Isdefault,IsActive,IsDeleted,Createdby,Modifiedby,Datecreated,Datemodified
       FROM Tenantroles a WHERE a.Isdefault =0 ORDER BY a.RoleId OFFSET @Offset ROWS FETCH NEXT @Count ROWS ONLY;

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