
--EXEC Usp_GetSystemLoyaltySchemeData @LoyaltySchemeDetails=''


CREATE PROCEDURE [dbo].[Usp_GetSystemLoyaltySchemeData]
	@LoyaltySchemeDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	
		BEGIN TRANSACTION;
		SET @LoyaltySchemeDetails =(
		SELECT(
		SELECT a.LSchemeId,a.LSchemeName,a.StartDate,a.EndDate,a.CreatedBy,a.ModifiedBy,a.DateCreated,a.DateModified,
        (
          SELECT  LSchemeRuleId,LSchemeId,bb.FormulaId,bb.FormulaName,cc.LRewardId,cc.RewardName,CalculateProdOrPaymode,aa.IsActive,IsApproved,ApprovalLevel,aa.CreatedBy,aa.ModifiedBy,aa.DateCreated,aa.DateModified,
		  (SELECT  aaa.StartTime FROM LSRuleTimes aaa WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId) AS StartTime,(SELECT aaa.EndTime FROM LSRuleTimes aaa WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId) AS EndTime,
		  (SELECT STRING_AGG(aaa.DaysofWeek, ',') FROM LSRuleDays aaa WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId) AS DaysofWeek,
		  (SELECT  STRING_AGG(bbb.Sname,',') FROM LSRuleStations aaa INNER JOIN SystemStations bbb ON aaa.StationId=bbb.Tenantstationid WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId)AS Station,
		  (SELECT STRING_AGG(bbb.Groupingname, ',') FROM LSRuleLoyaltyGrouping aaa INNER JOIN LoyaltyGroupings bbb ON aaa.GroupingId=bbb.GroupingId WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId)AS LoyaltyGrouping,
		  (SELECT STRING_AGG(bbb.Paymentmode, ',') AS Paymentmode FROM LSRulePaymentModes aaa INNER JOIN Paymentmodes bbb ON aaa.PaymentModeId=bbb.PaymentmodeId WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId)AS Paymentmode,
		  (SELECT   STRING_AGG(bbb.Productvariationname, ',') FROM LSRuleProducts aaa INNER JOIN SystemProductvariation bbb ON aaa.ProductvariationId=bbb.ProductvariationId WHERE aaa.LSchemeRuleId = aa.LSchemeRuleId)AS Product
		  FROM LSchemeRules aa
		  INNER JOIN LFormulas bb ON aa.FormulaId= bb.FormulaId
		  INNER JOIN LRewards cc ON aa.LRewardId= cc.LRewardId
            WHERE 
                aa.LSchemeId = a.LSchemeId
            FOR JSON PATH
        ) AS SystemSchemeRules
       FROM LSchemes a
		LEFT JOIN  SystemStaffs b ON a.CreatedBy=b.StaffId
		LEFT JOIN  SystemStaffs c ON a.ModifiedBy=c.StaffId
        FOR JSON PATH
		) AS LoyaltyScheme
		  FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		  )

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@LoyaltySchemeDetails as LoyaltySchemeDetails;

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