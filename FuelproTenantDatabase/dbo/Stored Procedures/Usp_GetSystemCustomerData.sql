CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerData]
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
	    SELECT CustomerId,a.Designation,CASE WHEN Designation='Corporate' THEN a.Companyname ELSE a.Firstname+' '+ a.Lastname END AS Customername,a.Emailaddress,f.Codename+''+a.Phonenumber AS CustomerPhone,a.Firstname,a.Lastname,a.Companyname,a.Phoneid,a.Phonenumber,a.Dob,
	    a.Gender,a.IDNumber,a.Designation,a.Pin,a.Pinharsh,a.CompanyAddress,a.ReferenceNumber,a.CompanyIncorporationDate,a.CompanyRegistrationNo,a.CompanyPIN,a.CompanyVAT,a.Contractstartdate,a.Contractenddate,a.StationId,a.CountryId,a.NoOfTransactionPerDay,a.AmountPerDay,
	    a.ConsecutiveTransTimeMin,a.IsPortaluser,a.IsActive,a.IsDeleted,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Createdby,a.Modifiedby,b.Sname AS CustomerRegStation,c.Countryname AS CountryName,d.FullName AS CustomerCreatedBy,e.FullName AS CustomerModofiedBy,a.Datecreated,a.Datemodified
		FROM Customers a
		INNER JOIN  SystemStations b ON a.StationId=b.Tenantstationid
		INNER JOIN SystemCountry c ON a.CountryId=c.CountryId
		INNER JOIN SystemStaffs d ON a.CreatedBy=d.UserId
		INNER JOIN SystemStaffs e ON a.ModifiedBy=e.UserId
		INNER JOIN SystemPhonecodes f ON a.PhoneId=f.PhoneId
		ORDER BY a.Datecreated
		OFFSET @Offset ROWS
		FETCH NEXT @Count ROWS ONLY;

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