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
		INSERT INTO GeneralSettings(TenantId,CompanyName,CompanyLogo,CompanyEmail,CompanyReference,CompanyPIN,IsCCEmail,CCEmail,StaffAutoLogOff,EmailAddress,EmailPassword,
        Messageusername,Messageapikey,ApplyTax,NoOfDecimalPlaces,IsEmailEnabled,IsSmsEnabled,IsTemplateTrancated,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Createdby,Modifiedby,DateCreated,DateModified)
	   (SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'),JSON_VALUE(@JsonObjectdata, '$.CompanyName'),JSON_VALUE(@JsonObjectdata, '$.CompanyLogo'),JSON_VALUE(@JsonObjectdata, '$.CompanyEmail'),JSON_VALUE(@JsonObjectdata, '$.CompanyReference'),
	   JSON_VALUE(@JsonObjectdata, '$.CompanyPIN'),JSON_VALUE(@JsonObjectdata, '$.IsCCEmail'),JSON_VALUE(@JsonObjectdata, '$.CCEmail'),1,JSON_VALUE(@JsonObjectdata, '$.EmailAddress'),JSON_VALUE(@JsonObjectdata, '$.EmailPassword'),
	   JSON_VALUE(@JsonObjectdata, '$.Messageusername'),JSON_VALUE(@JsonObjectdata, '$.Messageapikey'),JSON_VALUE(@JsonObjectdata, '$.ApplyTax'),JSON_VALUE(@JsonObjectdata, '$.NoOfDecimalPlaces'),JSON_VALUE(@JsonObjectdata, '$.IsEmailEnabled'),
	   JSON_VALUE(@JsonObjectdata, '$.IsSmsEnabled'),JSON_VALUE(@JsonObjectdata, '$.IsTemplateTrancated'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),
	   JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
	   JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2))
		Set @RespMsg ='Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE GeneralSettings 
		SET CompanyName=JSON_VALUE(@JsonObjectdata, '$.CompanyName'),CompanyEmail=JSON_VALUE(@JsonObjectdata, '$.CompanyEmail'),CompanyReference=JSON_VALUE(@JsonObjectdata, '$.CompanyReference'),
		   CompanyPIN=JSON_VALUE(@JsonObjectdata, '$.CompanyPIN'),IsCCEmail=JSON_VALUE(@JsonObjectdata, '$.IsCCEmail'),CCEmail=JSON_VALUE(@JsonObjectdata, '$.CCEmail'),EmailAddress=JSON_VALUE(@JsonObjectdata, '$.EmailAddress'),EmailPassword=JSON_VALUE(@JsonObjectdata, '$.EmailPassword'),
		   Messageusername=JSON_VALUE(@JsonObjectdata, '$.Messageusername'),Messageapikey=JSON_VALUE(@JsonObjectdata, '$.Messageapikey'),ApplyTax=JSON_VALUE(@JsonObjectdata, '$.ApplyTax'),NoOfDecimalPlaces=JSON_VALUE(@JsonObjectdata, '$.NoOfDecimalPlaces'),IsEmailEnabled=JSON_VALUE(@JsonObjectdata, '$.IsEmailEnabled'),
		   IsSmsEnabled=JSON_VALUE(@JsonObjectdata, '$.IsSmsEnabled'),IsTemplateTrancated=JSON_VALUE(@JsonObjectdata, '$.IsTemplateTrancated'),Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),
		   Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		   Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2)
		   WHERE GeneralSettId=JSON_VALUE(@JsonObjectdata, '$.GeneralSettId')
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