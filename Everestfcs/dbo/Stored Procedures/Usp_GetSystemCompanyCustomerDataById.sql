CREATE PROCEDURE [dbo].[Usp_GetSystemCompanyCustomerDataById]
	@CustomerId BIGINT
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
	   SELECT a.CustomerId,a.Firstname,a.Lastname,a.Companyname,a.Emailaddress,a.Phoneid,a.Phonenumber,a.Dob,a.Gender,a.IDNumber,a.Designation,a.Pin,a.Pinharsh,a.CompanyAddress,a.ReferenceNumber,a.CompanyIncorporationDate,
		   a.CompanyRegistrationNo,a.CompanyPIN,a.CompanyVAT,a.Contractstartdate,a.Contractenddate,a.StationId,a.CountryId,a.NoOfTransactionPerDay,a.AmountPerDay,a.ConsecutiveTransTimeMin,a.IsPortaluser,a.IsActive,
		    CASE WHEN Designation='Corporate' THEN a.Companyname ELSE a.Firstname+' '+ a.Lastname END AS Customername,b.Tenantname,b.Tenantsubdomain,b.TenantLogo,b.TenantEmail,b.TenantReference,b.TenantPIN,b.IsCCEmail,b.CCEmail,b.StaffAutoLogOff,b.EmailServer,b.EmailAddress AS EmailServerEmail,b.EmailPassword,b.Messageusername,b.Messageapikey,b.ApplyTax,b.NoOfDecimalPlaces,
			   b.IsEmailEnabled,b.IsSmsEnabled,b.IsTemplateTrancated, a.IsDeleted,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Createdby,a.Modifiedby,a.Datecreated,a.Datemodified
       FROM Customers a
	  	INNER JOIN TenantAccounts b ON a.Tenantid=b.Tenantid
	   WHERE CustomerId=@CustomerId

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
