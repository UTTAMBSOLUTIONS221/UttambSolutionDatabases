CREATE PROCEDURE [dbo].[Usp_Getallsystemloyaltysettingsdata]
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
	     SELECT a.LoyaltysettId,a.Tenantid,b.Tenantname, c.RewardName AS Fromreward,d.RewardName AS Toreward,a.NumberFormat,a.RoundofDecimals,a.CeilorFloor,a.PointsAwardLimitType,
			a.NoOfTransactionPerDay,a.AmountPerDay,a.IsApprovalOn,a.CollisionRule,a.SalesRangeStartDay,a.DelayedorInstant,a.AzureCronJobCycleMinutes,a.ConsecutiveTransTimeMin,
			a.MinRedeemPoints,a.VoucherUse,a.DaysToDeactivateNoTransAcc,a.ApplyLoyaltySettings,a.PeriodApplicable,a.FromRewardId,a.ToRewardId,a.ConversionValue,a.AutoRedeem,a.RedeemPeriod,a.RedeemDay,e.Firstname +' '+ e.Lastname  AS Createdby,f.Firstname +' '+ f.Lastname  AS Modifiedby,a.DateCreated,a.DateModified
	  FROM LoyaltySettings a
	  INNER JOIN Tenantaccounts b ON a.TenantId=b.TenantId
	  INNER JOIN Lrewards c ON a.FromRewardId =c.LRewardId
	  INNER JOIN LRewards d ON a.ToRewardId=d.LRewardId
	  INNER JOIN SystemStaffs e ON a.Createdby=e.Userid
	  INNER JOIN SystemStaffs f ON a.Modifiedby=f.Userid


	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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