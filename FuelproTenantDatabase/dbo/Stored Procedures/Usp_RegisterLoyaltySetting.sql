CREATE PROCEDURE [dbo].[Usp_RegisterLoyaltySetting]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.LoyaltysettId')=0)
		BEGIN
		INSERT INTO LoyaltySettings(NumberFormat,RoundofDecimals,CeilorFloor,PointsAwardLimitType,NoOfTransactionPerDay,AmountPerDay,IsApprovalOn,CollisionRule,SalesRangeStartDay,
		DelayedorInstant,AzureCronJobCycleMinutes,ConsecutiveTransTimeMin,MinRedeemPoints,VoucherUse,DaysToDeactivateNoTransAcc,ApplyLoyaltySettings,PeriodApplicable,
		Createdby,Modifiedby,DateCreated,DateModified)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.NumberFormat'),JSON_VALUE(@JsonObjectdata, '$.RoundofDecimals'),JSON_VALUE(@JsonObjectdata, '$.CeilorFloor'),'General',JSON_VALUE(@JsonObjectdata, '$.NoOfTransactionPerDay'),JSON_VALUE(@JsonObjectdata, '$.AmountPerDay'),
		1,JSON_VALUE(@JsonObjectdata, '$.CollisionRule'),1,'Instant',1,JSON_VALUE(@JsonObjectdata, '$.ConsecutiveTransTimeMin'),JSON_VALUE(@JsonObjectdata, '$.MinRedeemPoints'),
		'Multiple Vouchers & USE',JSON_VALUE(@JsonObjectdata, '$.DaysToDeactivateNoTransAcc'),JSON_VALUE(@JsonObjectdata, '$.ApplyLoyaltySettings'),'Daily',
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))

		Set @RespMsg ='Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE LoyaltySettings SET NumberFormat=JSON_VALUE(@JsonObjectdata, '$.NumberFormat'),RoundofDecimals=JSON_VALUE(@JsonObjectdata, '$.RoundofDecimals'),CeilorFloor=JSON_VALUE(@JsonObjectdata, '$.CeilorFloor'),NoOfTransactionPerDay=JSON_VALUE(@JsonObjectdata, '$.NoOfTransactionPerDay'),AmountPerDay=JSON_VALUE(@JsonObjectdata, '$.AmountPerDay'),CollisionRule=JSON_VALUE(@JsonObjectdata, '$.CollisionRule'),SalesRangeStartDay=JSON_VALUE(@JsonObjectdata, '$.SalesRangeStartDay'),
		AzureCronJobCycleMinutes=JSON_VALUE(@JsonObjectdata, '$.AzureCronJobCycleMinutes'),ConsecutiveTransTimeMin=JSON_VALUE(@JsonObjectdata, '$.ConsecutiveTransTimeMin'),MinRedeemPoints=JSON_VALUE(@JsonObjectdata, '$.MinRedeemPoints'),DaysToDeactivateNoTransAcc=JSON_VALUE(@JsonObjectdata, '$.DaysToDeactivateNoTransAcc'),ApplyLoyaltySettings=JSON_VALUE(@JsonObjectdata, '$.ApplyLoyaltySettings'),
		ModifiedBy=JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2)
	

		Set @RespMsg ='Updated Successfully.'
		Set @RespStat =0; 
		END
		
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