CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountEmployeeFrequencyPolicyData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeFrequencyId')=0)
		BEGIN
			IF EXISTS(SELECT EmployeeFrequencyId FROM EmployeeTransactionFrequency WHERE Frequency=JSON_VALUE(@JsonObjectdata, '$.Frequency') AND FrequencyPeriod=JSON_VALUE(@JsonObjectdata, '$.FrequencyPeriod'))
			BEGIN
				Select  1 as RespStatus, 'Similar Frequency exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
			IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeFrequencyId')>0)
			BEGIN
			    DELETE FROM EmployeeTransactionFrequency WHERE EmployeeId = JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AND EmployeeFrequencyId!=JSON_VALUE(@JsonObjectdata, '$.EmployeeFrequencyId');
				UPDATE EmployeeTransactionFrequency SET EmployeeId = JSON_VALUE(@JsonObjectdata, '$.EmployeeId') , Frequency=JSON_VALUE(@JsonObjectdata, '$.Frequency'),FrequencyPeriod=JSON_VALUE(@JsonObjectdata, '$.FrequencyPeriod'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE EmployeeFrequencyId=JSON_VALUE(@JsonObjectdata, '$.EmployeeFrequencyId')
			END
			ELSE
			BEGIN
			    DELETE FROM EmployeeTransactionFrequency WHERE EmployeeId = JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AND EmployeeFrequencyId!=JSON_VALUE(@JsonObjectdata, '$.EmployeeFrequencyId');			
				INSERT INTO EmployeeTransactionFrequency(EmployeeId,Frequency,FrequencyPeriod,Createdby,Modifiedby,DateCreated,DateModified)
				SELECT JSON_VALUE(@JsonObjectdata, '$.EmployeeId'),JSON_VALUE(@JsonObjectdata, '$.Frequency'),JSON_VALUE(@JsonObjectdata, '$.FrequencyPeriod'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
		   END

		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AS Data1, JSON_VALUE(@JsonObjectdata, '$.EmployeeName') AS Data2;

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
