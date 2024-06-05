CREATE PROCEDURE [dbo].[Usp_RegisterformulaRuleeditdata]
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
		 UPDATE LFormulaRules SET Range1=JSON_VALUE(@JsonObjectdata, '$.Range1'),Range2=JSON_VALUE(@JsonObjectdata, '$.Range2'),IsRangetoInfinity=JSON_VALUE(@JsonObjectdata, '$.IsRangetoInfinity'),Formula=JSON_VALUE(@JsonObjectdata, '$.Formula'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE FormulaRuleId=JSON_VALUE(@JsonObjectdata, '$.FormulaRuleId')
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
