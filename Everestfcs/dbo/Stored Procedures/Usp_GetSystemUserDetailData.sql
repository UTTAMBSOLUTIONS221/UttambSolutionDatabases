CREATE PROCEDURE [dbo].[Usp_GetSystemUserDetailData]
    @UserId BIGINT,
	@Staffdetaildata VARCHAR(MAX)  OUTPUT
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
		  SET @Staffdetaildata = (
			   SELECT a.Userid,a.Tenantid,a.Firstname,a.Lastname,a.Phoneid,a.Phonenumber,left(a.Username, charindex('@', a.Username) - 1) AS Username,a.Emailaddress,a.Roleid,a.Passharsh,a.Passwords,a.LimitTypeId,a.LimitTypeValue,a.Isactive,a.Isdeleted,a.Loginstatus,a.Passwordresetdate,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Createdby,a.Modifiedby,a.Lastlogin,a.Datemodified,a.Datecreated,
				(
				SELECT aa.UserId,aa.StationId FROM LnkStaffStation aa WHERE a.UserId=aa.UserId
				FOR JSON PATH
				) AS SystemStation 
				FROM SystemStaffs a WHERE a.UserId=@UserId
				FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
			  )
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
           SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@Staffdetaildata AS Staffdetaildata  
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
