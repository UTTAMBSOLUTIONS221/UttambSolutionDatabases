CREATE PROCEDURE [dbo].[Usp_GetSystemStaffUserDetailData]
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
			   SELECT a.Userid,a.Tenantid,a.Firstname,a.Lastname,a.Phoneid,a.Phonenumber,a.Username AS Username,a.Emailaddress,a.Roleid,a.Passharsh,a.Passwords,a.LimitTypeId,a.LimitTypeValue,
			   b.Tenantname,b.Tenantsubdomain,b.TenantLogo,b.TenantEmail,b.TenantReference,b.TenantPIN,b.IsCCEmail,b.CCEmail,b.StaffAutoLogOff,b.EmailServer,b.EmailAddress AS EmailServerEmail,b.EmailPassword,b.Messageusername,b.Messageapikey,b.ApplyTax,b.NoOfDecimalPlaces,
			   b.IsEmailEnabled,b.IsSmsEnabled,b.IsTemplateTrancated,a.Isactive,a.Isdeleted,a.Loginstatus,a.Passwordresetdate,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Createdby,a.Modifiedby,a.Lastlogin,a.Datemodified,a.Datecreated,
				(
				SELECT aa.UserId,aa.StationId FROM LnkStaffStation aa WHERE a.UserId=aa.UserId
				FOR JSON PATH
				) AS SystemStation 
				FROM SystemStaffs a 
				INNER JOIN TenantAccounts b ON a.Tenantid=b.Tenantid
				WHERE a.UserId=@UserId
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