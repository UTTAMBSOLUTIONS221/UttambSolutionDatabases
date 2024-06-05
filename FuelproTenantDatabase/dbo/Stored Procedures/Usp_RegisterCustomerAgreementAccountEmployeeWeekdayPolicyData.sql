CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountEmployeeWeekdayPolicyData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeWeekDaysId')=0)
		BEGIN
			IF EXISTS(SELECT EmployeeWeekDaysId FROM EmployeeWeekDays WHERE EmployeeId=JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AND WeekDays=JSON_VALUE(@JsonObjectdata, '$.WeekDays'))
			BEGIN
				Select  1 as RespStatus, 'Similar Weekdays exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
		    IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeWeekDaysId')>0)
			BEGIN
			    DELETE FROM EmployeeWeekDays WHERE EmployeeId = JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AND EmployeeWeekDaysId!=JSON_VALUE(@JsonObjectdata, '$.EmployeeWeekDaysId');
				UPDATE EmployeeWeekDays SET EmployeeId = JSON_VALUE(@JsonObjectdata, '$.EmployeeId'), WeekDays=JSON_VALUE(@JsonObjectdata, '$.WeekDays'),StartTime=JSON_VALUE(@JsonObjectdata, '$.StartTime'),EndTime=JSON_VALUE(@JsonObjectdata, '$.EndTime'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE EmployeeWeekDaysId=JSON_VALUE(@JsonObjectdata, '$.EmployeeWeekDaysId')
			END
			ELSE
			BEGIN
			DELETE FROM EmployeeWeekDays WHERE EmployeeId = JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AND EmployeeWeekDaysId!=JSON_VALUE(@JsonObjectdata, '$.EmployeeWeekDaysId');				
			INSERT INTO EmployeeWeekDays(EmployeeId,WeekDays,StartTime,EndTime,Createdby,Modifiedby,DateCreated,DateModified)
			SELECT JSON_VALUE(@JsonObjectdata, '$.EmployeeId'),JSON_VALUE(@JsonObjectdata, '$.WeekDays'),JSON_VALUE(@JsonObjectdata, '$.StartTime'),JSON_VALUE(@JsonObjectdata, '$.EndTime'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),
			CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
			END

		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AS Data1;

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