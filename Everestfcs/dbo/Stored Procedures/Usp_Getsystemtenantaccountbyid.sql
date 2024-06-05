CREATE PROCEDURE [dbo].[Usp_Getsystemtenantaccountbyid] 
@TenantId BIGINT
AS 
BEGIN
	SELECT Tenantid,Countryid,Tenantname,Tenantsubdomain,TenantLogo,TenantEmail,Phoneid,Phonenumber,TenantReference,TenantPIN,IsCCEmail,CCEmail,StaffAutoLogOff,EmailServer,EmailAddress,
	 EmailPassword,MessageUrl,Messageusername,Messageapikey,ApplyTax,NoOfDecimalPlaces,IsEmailEnabled,IsSmsEnabled,IsTemplateTrancated,Extra,Extra1,Extra2,Extra3,Extra4,
	 Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Tenantloginstatus,Isactive,Isdeleted,Createdby,Modifiedby,DateCreated,DateModified
	FROM Tenantaccounts WHERE Tenantid=@TenantId
  END