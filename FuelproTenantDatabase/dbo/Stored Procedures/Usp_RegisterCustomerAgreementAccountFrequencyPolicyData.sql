CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountFrequencyPolicyData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.AccountFrequencyId')=0)
		BEGIN
			IF EXISTS(SELECT AccountFrequencyId FROM AccountTransactionFrequency WHERE Frequency=JSON_VALUE(@JsonObjectdata, '$.Frequency') AND FrequencyPeriod=JSON_VALUE(@JsonObjectdata, '$.FrequencyPeriod'))
			BEGIN
				Select  1 as RespStatus, 'Similar Frequency exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
		   IF(JSON_VALUE(@JsonObjectdata, '$.AccountFrequencyId')>0)
			BEGIN
			    DELETE FROM AccountTransactionFrequency WHERE AccountId = JSON_VALUE(@JsonObjectdata, '$.AccountId') AND AccountFrequencyId!=JSON_VALUE(@JsonObjectdata, '$.AccountFrequencyId');
				UPDATE AccountTransactionFrequency SET AccountId = JSON_VALUE(@JsonObjectdata, '$.AccountId') , Frequency=JSON_VALUE(@JsonObjectdata, '$.Frequency'),FrequencyPeriod=JSON_VALUE(@JsonObjectdata, '$.FrequencyPeriod'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE AccountFrequencyId=JSON_VALUE(@JsonObjectdata, '$.AccountFrequencyId')
			END
			ELSE
			BEGIN
			    DELETE FROM AccountTransactionFrequency WHERE AccountId = JSON_VALUE(@JsonObjectdata, '$.AccountId') AND AccountFrequencyId!=JSON_VALUE(@JsonObjectdata, '$.AccountFrequencyId');			
				INSERT INTO AccountTransactionFrequency(AccountId,Frequency,FrequencyPeriod,Createdby,Modifiedby,DateCreated,DateModified)
				SELECT JSON_VALUE(@JsonObjectdata, '$.AccountId'),JSON_VALUE(@JsonObjectdata, '$.Frequency'),JSON_VALUE(@JsonObjectdata, '$.FrequencyPeriod'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
			END
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,JSON_VALUE(@JsonObjectdata, '$.AccountId') AS Data1, JSON_VALUE(@JsonObjectdata, '$.Masknumber') AS Data2;

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