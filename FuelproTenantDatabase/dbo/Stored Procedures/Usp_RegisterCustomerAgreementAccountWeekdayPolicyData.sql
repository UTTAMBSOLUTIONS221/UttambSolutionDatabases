CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountWeekdayPolicyData]
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
			IF EXISTS(SELECT AccountWeekDaysId FROM AccountWeekDays WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') AND WeekDays=JSON_VALUE(@JsonObjectdata, '$.WeekDays'))
			BEGIN
				Select  1 as RespStatus, 'Similar Weekdays exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
            IF(JSON_VALUE(@JsonObjectdata, '$.AccountWeekDaysId')>0)
			BEGIN
			    DELETE FROM AccountWeekDays WHERE AccountId = JSON_VALUE(@JsonObjectdata, '$.AccountId') AND AccountWeekDaysId!=JSON_VALUE(@JsonObjectdata, '$.AccountWeekDaysId');
				UPDATE AccountWeekDays SET AccountId = JSON_VALUE(@JsonObjectdata, '$.AccountId'), WeekDays=JSON_VALUE(@JsonObjectdata, '$.WeekDays'),StartTime=JSON_VALUE(@JsonObjectdata, '$.StartTime'),EndTime=JSON_VALUE(@JsonObjectdata, '$.EndTime'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE AccountWeekDaysId=JSON_VALUE(@JsonObjectdata, '$.AccountWeekDaysId')
			END
			ELSE
			BEGIN
				DELETE FROM AccountWeekDays WHERE AccountId = JSON_VALUE(@JsonObjectdata, '$.AccountId') AND AccountWeekDaysId!=JSON_VALUE(@JsonObjectdata, '$.AccountWeekDaysId');
				INSERT INTO AccountWeekDays(AccountId,WeekDays,StartTime,EndTime,Createdby,Modifiedby,DateCreated,DateModified)
				SELECT JSON_VALUE(@JsonObjectdata, '$.AccountId'),JSON_VALUE(@JsonObjectdata, '$.WeekDays'),JSON_VALUE(@JsonObjectdata, '$.StartTime'),JSON_VALUE(@JsonObjectdata, '$.EndTime'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),
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