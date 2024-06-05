CREATE PROCEDURE [dbo].[Usp_Getsystemtenantaccountdata] 
AS 
BEGIN
SELECT a.Tenantid,b.Countryname,b.Currencyname,b.Utcname,a.Tenantname,a.Tenantsubdomain,a.TenantLogo,a.TenantEmail,e.Codename+''+a.Phonenumber AS Phonenumber,a.TenantReference,a.TenantPIN,a.IsCCEmail
      ,a.CCEmail,a.StaffAutoLogOff,a.EmailAddress,a.EmailPassword,a.Messageusername,a.Messageapikey,a.ApplyTax
      ,a.NoOfDecimalPlaces,a.IsEmailEnabled,a.IsSmsEnabled,a.IsTemplateTrancated,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra8,a.Extra9
      ,a.Extra10,a.Tenantloginstatus,a.Isactive,a.Isdeleted,c.Firstname +' '+ c.Lastname AS Createdby,d.Firstname +' '+ d.Lastname AS Modifiedby,a.DateCreated,a.DateModified
  FROM Tenantaccounts a
  INNER JOIN SystemCountry b ON a.Countryid=b.CountryId
  INNER JOIN SystemPhoneCodes e ON a.Phoneid=e.Phoneid
  LEFT JOIN SystemStaffs c ON a.Createdby=c.Userid
  LEFT JOIN SystemStaffs d ON a.Modifiedby =d.Userid
  END