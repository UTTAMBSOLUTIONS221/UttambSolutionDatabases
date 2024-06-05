CREATE PROCEDURE [dbo].[Usp_RegisterLoyaltyFormulaData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@FormulaId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate
		IF EXISTS(SELECT FormulaId FROM LFormulas WHERE FormulaName=JSON_VALUE(@JsonObjectdata, '$.FormulaName') AND Tenantid= JSON_VALUE(@JsonObjectdata, '$.TenantId'))
		Begin
		    Select  1 as RespStatus, 'Similar Name Exists' as RespMessage;
			Return
		End
		BEGIN TRANSACTION;
		INSERT INTO LFormulas(TenantId,FormulaName,ValueType,CreatedBy,ModifiedBy,DateCreated,DateModified)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'),JSON_VALUE(@JsonObjectdata, '$.FormulaName'),JSON_VALUE(@JsonObjectdata, '$.ValueType'),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))

		SET @FormulaId = SCOPE_IDENTITY();
		 
		INSERT INTO LFormulaRules(FormulaId,Range1,Range2,IsRangetoInfinity,Formula,CreatedBy,ModifiedBy,DateCreated,DateModified)
		SELECT @FormulaId, Range1,Range2,IsRangetoInfinity,Formula,CreatedbyId ,ModifiedId,Datecreated ,Datemodified
		FROM OPENJSON (@JsonObjectdata, '$.Formularules')
		WITH (
			Range1 DECIMAL(18,2),
			Range2 DECIMAL(18,2),
			IsRangetoInfinity BIT,
			Formula VARCHAR(100),
			CreatedbyId BIGINT,
			ModifiedId BIGINT,
			Datecreated DATETIME,
			Datemodified DATETIME
		)

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
