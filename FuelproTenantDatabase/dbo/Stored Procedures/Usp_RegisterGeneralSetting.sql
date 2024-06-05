CREATE PROCEDURE [dbo].[Usp_RegisterGeneralSetting]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @GeneralSettId BIGINT = 0,
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.GeneralSettId')=0)
		BEGIN
		INSERT INTO GeneralSettings(CurrencyId,PhoneId,CountryId,CompanyName,CompanyEmail,CompanyPIN,CompanyReference,IndividualMultipleAccounts,CcEmail,IsCCEmail,emailCustomerAutomatically,timeZone,timeZoneOffSet,staffAutoLogOff,
			ApplyTax,noOfDecimalPlaces,isEmailEnabled,isSmsEnabled,isTemplateTrancated,createdby,Modifiedby,DateCreated,DateModified)
			(SELECT JSON_VALUE(@JsonObjectdata, '$.CurrencyId'),JSON_VALUE(@JsonObjectdata, '$.PhoneId'),JSON_VALUE(@JsonObjectdata, '$.CountryId'),JSON_VALUE(@JsonObjectdata, '$.CompanyName'),JSON_VALUE(@JsonObjectdata, '$.CompanyEmail'),
			JSON_VALUE(@JsonObjectdata, '$.CompanyPIN'),JSON_VALUE(@JsonObjectdata, '$.CompanyReference'),JSON_VALUE(@JsonObjectdata, '$.IndividualMultipleAccounts'),JSON_VALUE(@JsonObjectdata, '$.CCEmail'),JSON_VALUE(@JsonObjectdata, '$.IsCCEmail'),JSON_VALUE(@JsonObjectdata, '$.EmailCustomerAutomatically'),
			JSON_VALUE(@JsonObjectdata, '$.TimeZone'),JSON_VALUE(@JsonObjectdata, '$.TimeZoneOffSet'),JSON_VALUE(@JsonObjectdata, '$.StaffAutoLogOff'),JSON_VALUE(@JsonObjectdata, '$.ApplyTax'),
			JSON_VALUE(@JsonObjectdata, '$.NoOfDecimalPlaces'),JSON_VALUE(@JsonObjectdata, '$.IsEmailEnabled'),JSON_VALUE(@JsonObjectdata, '$.IsSmsEnabled'),JSON_VALUE(@JsonObjectdata, '$.IsTemplateTrancated'),
			JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		    CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2))

		Set @RespMsg ='Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE GeneralSettings 
		SET CurrencyId=JSON_VALUE(@JsonObjectdata, '$.CurrencyId'),PhoneId=JSON_VALUE(@JsonObjectdata, '$.PhoneId'),CountryId=JSON_VALUE(@JsonObjectdata, '$.CountryId'),CompanyName=JSON_VALUE(@JsonObjectdata, '$.CompanyName'),
		CompanyEmail=JSON_VALUE(@JsonObjectdata, '$.CompanyEmail'),CompanyPIN=JSON_VALUE(@JsonObjectdata, '$.CompanyPIN'),CompanyReference=JSON_VALUE(@JsonObjectdata, '$.CompanyReference'),IndividualMultipleAccounts=JSON_VALUE(@JsonObjectdata, '$.IndividualMultipleAccounts'),
		CCEmail=JSON_VALUE(@JsonObjectdata, '$.CCEmail'),IsCCEmail=JSON_VALUE(@JsonObjectdata, '$.IsCCEmail'),EmailCustomerAutomatically=JSON_VALUE(@JsonObjectdata, '$.EmailCustomerAutomatically'),
		TimeZone=JSON_VALUE(@JsonObjectdata, '$.TimeZone'),TimeZoneOffSet=JSON_VALUE(@JsonObjectdata, '$.TimeZoneOffSet'),StaffAutoLogOff=JSON_VALUE(@JsonObjectdata, '$.StaffAutoLogOff'),
		ApplyTax=JSON_VALUE(@JsonObjectdata, '$.ApplyTax'),noOfDecimalPlaces=JSON_VALUE(@JsonObjectdata, '$.NoOfDecimalPlaces'),IsEmailEnabled=JSON_VALUE(@JsonObjectdata, '$.IsEmailEnabled'),
		IsSmsEnabled=JSON_VALUE(@JsonObjectdata, '$.IsSmsEnabled'),IsTemplateTrancated=JSON_VALUE(@JsonObjectdata, '$.IsTemplateTrancated'),
		ModifiedBy=JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2)
		Set @RespMsg ='Updated Successfully.'
		Set @RespStat =0; 
		END
		
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage;

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