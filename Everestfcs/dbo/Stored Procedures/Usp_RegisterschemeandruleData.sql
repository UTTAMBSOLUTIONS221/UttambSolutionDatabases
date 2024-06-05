CREATE PROCEDURE [dbo].[Usp_RegisterschemeandruleData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@LSchemeId BIGINT,
			@LSchemeRuleId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate
		IF EXISTS(SELECT LSchemeId FROM LSchemes WHERE LSchemeName=JSON_VALUE(@JsonObjectdata, '$.LSchemeName') AND Tenantid= JSON_VALUE(@JsonObjectdata, '$.TenantId'))
		Begin
		    Select  1 as RespStatus, 'Similar Name Exists' as RespMessage;
			Return
		End
		BEGIN TRANSACTION;
		INSERT INTO LSchemes(TenantId,LSchemeName,StartDate,EndDate,IsActive,CreatedBy,ModifiedBy,DateCreated,DateModified)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'),JSON_VALUE(@JsonObjectdata, '$.LSchemeName'),CAST(JSON_VALUE(@JsonObjectdata, '$.StartDate')  AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.EndDate')  AS datetime2),
		1,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))

		SET @LSchemeId = SCOPE_IDENTITY();
		 
		INSERT INTO LSchemeRules(LSchemeId,FormulaId,LRewardId,CalculateProdOrPaymode,IsActive,IsApproved,ApprovalLevel,CreatedBy,ModifiedBy,DateCreated,DateModified)
		SELECT @LSchemeId, FormulaId,LRewardId,'Product',1,0,'Pending',CreatedbyId ,ModifiedId,Datecreated ,Datemodified
		FROM OPENJSON (@JsonObjectdata, '$.Schemerules') WITH (FormulaId BIGINT,LRewardId BIGINT,CreatedbyId BIGINT,ModifiedId BIGINT,Datecreated DATETIME,Datemodified DATETIME)

		SET @LSchemeRuleId = SCOPE_IDENTITY();

		-- Extract and insert SchemeRule Days
		INSERT INTO LSRuleDays(LSchemeRuleId,DaysofWeek)
	    SELECT @LSchemeRuleId, [value] FROM OPENJSON (@JsonObjectdata, '$.Schemerules[0].DaysApplicable');

		-- Extract and insert SchemeRule STations
		INSERT INTO LSRuleStations(LSchemeRuleId,StationId)
	    SELECT @LSchemeRuleId, [value] FROM OPENJSON (@JsonObjectdata, '$.Schemerules[0].StationId');

		-- Extract and insert SchemeRule Products
		INSERT INTO LSRuleProducts(LSchemeRuleId,ProductvariationId)
	    SELECT @LSchemeRuleId, [value] FROM OPENJSON (@JsonObjectdata, '$.Schemerules[0].ProductId');

		-- Extract and insert SchemeRule Payment Mode
		INSERT INTO LSRulePaymentModes(LSchemeRuleId,PaymentModeId)
	    SELECT @LSchemeRuleId, [value] FROM OPENJSON (@JsonObjectdata, '$.Schemerules[0].PaymentmodeId');

		-- Extract and insert SchemeRule Payment Mode
		INSERT INTO LSRuleLoyaltyGrouping(LSchemeRuleId,GroupingId)
	    SELECT @LSchemeRuleId, [value] FROM OPENJSON (@JsonObjectdata, '$.Schemerules[0].LoyaltygroupId');

	     -- Extract and insert SchemeRule Time 
		INSERT INTO LSRuleTimes(LSchemeRuleId,StartTime,EndTime)
	   (SELECT @LSchemeRuleId, JSON_VALUE(@JsonObjectdata, '$.Schemerules[0].StartTime'), JSON_VALUE(@JsonObjectdata, '$.Schemerules[0].EndTime'))

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
