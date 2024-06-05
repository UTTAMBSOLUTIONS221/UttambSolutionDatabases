CREATE PROCEDURE [dbo].[Usp_PostReverseSaleTransactionData]
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
		SELECT 'TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),FinanceTransactionTypeId,FinanceTransactionSubTypeId, 
		(SELECT CloseDayId FROM CloseDays WHERE EndDate =(DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(CONVERT(DATE, dbo.getlocaldate()) AS DATETIME))))), JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'),
		'Reverse',SaleRefence,IsOnlineSale,1,IsDeletd,AutomationRefence,JSON_VALUE(@JsonObjectdata, '$.StaffId'),ActualDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6))
		FROM FinanceTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
		SET @FinanceTransactionId = SCOPE_IDENTITY();

		INSERT INTO SystemTickets(FinanceTransactionId,StaffId,StationId,AccountId,Createdby,ActualDate,DateCreated)
		SELECT @FinanceTransactionId,StaffId,StationId,AccountId,JSON_VALUE(@JsonObjectdata, '$.StaffId'),ActualDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM SystemTickets WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
		SET @NewTicketId = SCOPE_IDENTITY();
		SET @TicketId =(SELECT TicketId FROM SystemTickets WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'))
		
		INSERT INTO Ticketlines (TicketId, productVariationId, Units, Price,Discount,Createdby,DateCreated)
		SELECT @NewTicketId,ProductvariationId,Units,Price,Discount,JSON_VALUE(@JsonObjectdata, '$.StaffId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM  Ticketlines WHERE TicketId=@TicketId

		INSERT INTO TicketlinePayments (TicketId, PaymentmodeId, TotalPaid, TotalUsed, mpesaCode, mpesaMSISDN,DateCreated)
		SELECT @NewTicketId,PaymentmodeId,-1*(TotalPaid),-1*(TotalUsed),MpesaCode,MpesaMSISDN,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6))  FROM TicketlinePayments WHERE TicketId=@TicketId

		If((SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='Card') IN (SELECT PaymentmodeId FROM TicketlinePayments WHERE TicketId=@TicketId))
		 BEGIN
			INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
			SELECT TOP 1 @FinanceTransactionId,ChartofAccountId,(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),Currency,-1*(Amount),GlActualDate, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM GLTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
			INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
			SELECT TOP 1 @FinanceTransactionId,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Payable'),(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),Currency,-1*(Amount),GlActualDate, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM GLTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
		END
		--ELSE If((SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='IVoucher') IN (SELECT PaymentmodeId FROM TicketlinePayments WHERE TicketId=@TicketId))
		--BEGIN
		--END
		 
		IF EXISTS(SELECT A.LRADataInputId FROM LRADataInputs A INNER JOIN LRResults B ON A.LRADataInputId=B.LRADataInputId WHERE A.FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'))
		BEGIN
		  INSERT INTO LRADataInputs(FinanceTransactionId,GroupingId,AccountId,StationId,TransactionDate,TransactionTime,TransactionDay,IsProcessed,IsRejected,RejectReason,IsActive,IsDeleted,Createdby,Modifiedby,DateCreated ,DateModified)
		  SELECT @FinanceTransactionId,GroupingId,AccountId,StationId,TransactionDate,TransactionTime,TransactionDay,IsProcessed,IsRejected,RejectReason,IsActive,IsDeleted,JSON_VALUE(@JsonObjectdata, '$.StaffId'),JSON_VALUE(@JsonObjectdata, '$.StaffId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) ,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM LRADataInputs WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId')
		  SET @LraDataInputId=(SELECT A.LRADataInputId FROM LRADataInputs A WHERE A.FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'))
		  SET @NewLraDataInputId = SCOPE_IDENTITY();
		  INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
		  SELECT AccountId,LRewardId,LTransactionTypeId,@NewLraDataInputId,LRConversionDataInputId,-1*(RewardAmount),IsActive,IsDeleted,JSON_VALUE(@JsonObjectdata, '$.StaffId'),JSON_VALUE(@JsonObjectdata, '$.StaffId'),ActualDateCreated,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) ,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6))  FROM LRResults WHERE LRADataInputId=@LraDataInputId;
		END

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