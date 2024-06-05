CREATE PROCEDURE [dbo].[Usp_PostReverseTopupTransactionData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Agreementtypename VARCHAR(100),
			@FinanceTransactionId BIGINT,
			@TicketId BIGINT,
			@NewTicketId BIGINT,
			@LraDataInputId BIGINT,
			@NewLraDataInputId BIGINT,
			@AutomationReference VARCHAR(70),
		    @TransactionReference VARCHAR(40),
			@TransactionDescription VARCHAR(20),
			@TransactionRewardAmount DECIMAL(34,2)= 0,
			@AccountId BIGINT,
			@AmountBeingSpent  DECIMAL(34,2)= 0,
			@QuantitySpent  DECIMAL(34,2)= 0,
			@RecurrentAllowedDebt  DECIMAL(34,2)= 0,
			@FirstDateofMonth  DATETIME,
			@EndDateofMonth  DATETIME,
			@LimitValueType VARCHAR(100),
			@BillingBasis VARCHAR(100);
	BEGIN
		BEGIN TRY	
		--Validate
		IF NOT EXISTS(SELECT FinanceTransactionId FROM FinanceTransactions WHERE FinanceTransactionId =JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'))
		 BEGIN 
			 Select  1 as RespStatus, 'Transaction Not Found!. Kindly Contact Admin' as RespMessage;
			 return;
		 END
		 IF((SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=(SELECT AccountId FROM CustomerAccountTopups WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'))))),0) * -1)< (SELECT Amount FROM CustomerAccountTopups WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId')))
		 BEGIN
		   Select  1 as RespStatus, 'Insufficient Balance!. Kindly Contact Admin' as RespMessage;
		   return;
		 END

		IF NOT EXISTS(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime)))))
		BEGIN
		 INSERT INTO SystemPeriods 
		 SELECT  DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime)));
		END
		IF NOT EXISTS(SELECT CloseDayId FROM CloseDays WHERE StartDate = (CONVERT(datetime, CONVERT(date, dbo.getlocaldate())) + '00:00:00'))
		BEGIN
			INSERT INTO CloseDays VALUES((CONVERT(datetime, CONVERT(date, dbo.getlocaldate())) + '00:00:00'),(CONVERT(datetime, CONVERT(date, dbo.getlocaldate())) + '23:59:59'))
		END
		IF NOT EXISTS(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime)))))
		BEGIN
		 INSERT INTO SystemPeriods 
		 SELECT  DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime)));
		END
		BEGIN TRANSACTION;
		UPDATE FinanceTransactions SET Isreversed=1 WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');

		INSERT INTO FinanceTransactions(TransactionCode,FinanceTransactionTypeId,FinanceTransactionSubTypeId,CloseDayId,ParentId,Saledescription,SaleRefence,IsOnlineSale,Isreversed,IsDeletd,AutomationRefence,Createdby,ActualDate,DateCreated)
		SELECT 'TOP'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),FinanceTransactionTypeId,FinanceTransactionSubTypeId, 
		(SELECT CloseDayId FROM CloseDays WHERE EndDate =(DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(CONVERT(DATE, dbo.getlocaldate()) AS DATETIME))))), JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'),
		'TopupReverse','Topup Reverse',IsOnlineSale,1,IsDeletd,AutomationRefence,JSON_VALUE(@JsonObjectdata, '$.StaffId'),ActualDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6))
		FROM FinanceTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
		SET @FinanceTransactionId = SCOPE_IDENTITY();



		INSERT INTO CustomerAccountTopups(FinanceTransactionId,AccountId,StationId,StaffId,ModeofPayment,Topupreference,Amount,Erprefe,Chequeno,Bankaccno,Drawerbank,Payeebank,Branchdeposited,Depositslip,Createdby,DateCreated)
		SELECT @FinanceTransactionId,AccountId,StationId,StaffId,ModeofPayment,'Topup Reverse',-1*(Amount),Erprefe,Chequeno,Bankaccno,Drawerbank,Payeebank,Branchdeposited,Depositslip,JSON_VALUE(@JsonObjectdata, '$.StaffId'), TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM CustomerAccountTopups WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		SELECT TOP 1 @FinanceTransactionId,ChartofAccountId,(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),Currency,-1*(Amount),GlActualDate, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM GLTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		SELECT TOP 1 @FinanceTransactionId,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Receivable'),(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),Currency,-1*(Amount),GlActualDate, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM GLTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');

		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		 Select @RespStat as RespStatus, @RespMsg as RespMessage;
		END TRY
		BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ''
		PRINT  error_line();
		PRINT 'Error ' + error_message();
		Select 2 as RespStatus, '0 - Error(s) Occurred' + error_message() as RespMessage
		END CATCH
		Select @RespStat as RespStatus, @RespMsg as RespMessage;
		RETURN; 
		END;
	END
END