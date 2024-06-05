CREATE PROCEDURE [dbo].[Usp_GetSystemLoyaltyschemeRuleDataById]
@LSchemeRuleId BIGINT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		BEGIN TRANSACTION;
		SELECT  
			aa.LSchemeRuleId,
			aa.LSchemeId,
			aa.FormulaId,
			aa.LRewardId,
			aa.CalculateProdOrPaymode,
			aa.IsActive,
			aa.IsApproved,
			aa.ApprovalLevel,
			aa.CreatedBy,
			aa.ModifiedBy,
			aa.DateCreated,
			aa.DateModified,
			(
				SELECT aaa.StartTime 
				FROM LSRuleTimes aaa 
				WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId
			) AS StartTime,
			(
				SELECT aaa.EndTime 
				FROM LSRuleTimes aaa 
				WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId
			) AS EndTime,
			(
				SELECT STRING_AGG(REPLACE(aaa.DaysofWeek, ' ', ''), ',') 
				FROM LSRuleDays aaa 
				WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId 
			) AS DaysOfWeek,
			(
				SELECT STRING_AGG(aaa.StationId, ',') 
				FROM LSRuleStations aaa 
				INNER JOIN SystemStations bbb ON aaa.StationId = bbb.StationId 
				WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId 
			) AS Stations,
			(
				SELECT STRING_AGG(bbb.GroupingId, ',') 
				FROM LSRuleLoyaltyGrouping aaa 
				INNER JOIN LoyaltyGroupings bbb ON aaa.GroupingId = bbb.GroupingId 
				WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId 
			) AS Loyaltygroups,
			(
				SELECT STRING_AGG(bbb.PaymentModeId, ',')
				FROM LSRulePaymentModes aaa 
				INNER JOIN Paymentmodes bbb ON aaa.PaymentModeId = bbb.PaymentmodeId 
				WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId 
			) AS Paymentmodes,
			(
				SELECT STRING_AGG(bbb.ProductvariationId, ',')
				FROM LSRuleProducts aaa 
				INNER JOIN SystemProductvariation bbb ON aaa.ProductvariationId = bbb.ProductvariationId 
				WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId 
			) AS Products
		FROM 
			LSchemeRules aa
		WHERE aa.LSchemeRuleId=@LSchemeRuleId
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage;
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