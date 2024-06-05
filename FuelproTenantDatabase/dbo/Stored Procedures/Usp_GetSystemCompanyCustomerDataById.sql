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
	   SELECT CustomerId,Firstname,Lastname,Companyname,Emailaddress,Phoneid,Phonenumber,Dob,Gender,IDNumber,Designation,Pin,Pinharsh,CompanyAddress,ReferenceNumber,CompanyIncorporationDate,
		   CompanyRegistrationNo,CompanyPIN,CompanyVAT,Contractstartdate,Contractenddate,StationId,CountryId,NoOfTransactionPerDay,AmountPerDay,ConsecutiveTransTimeMin,IsPortaluser,IsActive,
		   IsDeleted,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Createdby,Modifiedby,Datecreated,Datemodified
       FROM Customers WHERE CustomerId=@CustomerId

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