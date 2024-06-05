CREATE PROCEDURE [dbo].[Usp_Getsystemloyaltysettingsdatabyid]
@LoyaltysettId BIGINT
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
	    SELECT LoyaltysettId,Tenantid,NumberFormat,RoundofDecimals,CeilorFloor,PointsAwardLimitType,NoOfTransactionPerDay,AmountPerDay,IsApprovalOn,CollisionRule,
			 SalesRangeStartDay,DelayedorInstant,AzureCronJobCycleMinutes,ConsecutiveTransTimeMin,MinRedeemPoints,VoucherUse,DaysToDeactivateNoTransAcc,ApplyLoyaltySettings,
			 PeriodApplicable,FromRewardId,ToRewardId,ConversionValue,AutoRedeem,RedeemPeriod,RedeemDay,Createdby,Modifiedby,DateCreated,DateModified
		FROM LoyaltySettings WHERE LoyaltysettId=@LoyaltysettId
	    Set @RespMsg ='Ok.'
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