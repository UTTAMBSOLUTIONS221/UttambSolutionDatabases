CREATE PROCEDURE [dbo].[Usp_Registerschemeruleeditdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		DECLARE @LSchemeRuleId INT = (SELECT JSON_VALUE(@JsonObjectdata, '$.LSchemeRuleId'));

		 UPDATE LSchemeRules SET FormulaId=JSON_VALUE(@JsonObjectdata, '$.FormulaId'),LRewardId=JSON_VALUE(@JsonObjectdata, '$.LRewardId'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2) WHERE LSchemeRuleId=JSON_VALUE(@JsonObjectdata, '$.LSchemeRuleId')
		-- Delete rows that are no longer present in the JSON
		DELETE FROM LSRuleDays WHERE LSchemeRuleId = @LSchemeRuleId AND NOT EXISTS (SELECT 1 FROM OPENJSON(@JsonObjectdata, '$.DaysApplicable') WHERE [value] = LSRuleDays.DaysofWeek)
		-- Insert new rows from the JSON
		INSERT INTO LSRuleDays (LSchemeRuleId, DaysofWeek) SELECT @LSchemeRuleId, [value] FROM OPENJSON(@JsonObjectdata, '$.DaysApplicable') WHERE [value] NOT IN (SELECT DaysofWeek FROM LSRuleDays WHERE LSchemeRuleId = @LSchemeRuleId)
		-- Delete rows that are no longer present in the JSON
		DELETE FROM LSRuleStations WHERE LSchemeRuleId = @LSchemeRuleId AND StationId NOT IN (SELECT [value] FROM OPENJSON(@JsonObjectdata, '$.StationId'))
		-- Insert new rows from the JSON
		INSERT INTO LSRuleStations (LSchemeRuleId, StationId) SELECT @LSchemeRuleId, [value] FROM OPENJSON(@JsonObjectdata, '$.StationId') WHERE [value] NOT IN (SELECT StationId FROM LSRuleStations WHERE LSchemeRuleId = @LSchemeRuleId)
		
		-- Delete rows that are no longer present in the JSON
        DELETE FROM LSRuleProducts WHERE LSchemeRuleId = @LSchemeRuleId AND ProductvariationId NOT IN (SELECT [value] FROM OPENJSON(@JsonObjectdata, '$.ProductId'))
		-- Insert new rows from the JSON
		INSERT INTO LSRuleProducts (LSchemeRuleId, ProductvariationId)SELECT @LSchemeRuleId, [value] FROM OPENJSON(@JsonObjectdata, '$.ProductId') WHERE [value] NOT IN (SELECT ProductvariationId FROM LSRuleProducts WHERE LSchemeRuleId = @LSchemeRuleId)

		-- Delete rows that are no longer present in the JSON
        DELETE FROM LSRulePaymentModes WHERE LSchemeRuleId = @LSchemeRuleId AND PaymentModeId NOT IN (SELECT [value] FROM OPENJSON(@JsonObjectdata, '$.PaymentmodeId'))
		-- Insert new rows from the JSON
		INSERT INTO LSRulePaymentModes (LSchemeRuleId, PaymentModeId) SELECT @LSchemeRuleId, [value] FROM OPENJSON(@JsonObjectdata, '$.PaymentmodeId')WHERE [value] NOT IN (SELECT PaymentModeId FROM LSRulePaymentModes WHERE LSchemeRuleId = @LSchemeRuleId)

		-- Delete rows that are no longer present in the JSON
        DELETE FROM LSRuleLoyaltyGrouping WHERE LSchemeRuleId = @LSchemeRuleId AND GroupingId NOT IN (SELECT [value] FROM OPENJSON(@JsonObjectdata, '$.LoyaltygroupId'))
		-- Insert new rows from the JSON
		INSERT INTO LSRuleLoyaltyGrouping (LSchemeRuleId, GroupingId) SELECT @LSchemeRuleId, [value] FROM OPENJSON(@JsonObjectdata, '$.LoyaltygroupId') WHERE [value] NOT IN (SELECT GroupingId FROM LSRuleLoyaltyGrouping WHERE LSchemeRuleId = @LSchemeRuleId)

		UPDATE LSRuleTimes SET StartTime=JSON_VALUE(@JsonObjectdata, '$.StartTime'),EndTime=JSON_VALUE(@JsonObjectdata, '$.EndTime') WHERE LSchemeRuleId=@LSchemeRuleId

		Set @RespMsg ='Success'
		Set @RespStat =0; 
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