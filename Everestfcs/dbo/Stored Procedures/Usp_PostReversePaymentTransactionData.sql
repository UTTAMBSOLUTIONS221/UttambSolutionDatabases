CREATE PROCEDURE [dbo].[Usp_PostReversePaymentTransactionData]
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

		IF NOT EXISTS(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))), 0) AS datetime)))))
		BEGIN
		 INSERT INTO SystemPeriods 
		 SELECT  DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))), 0) AS datetime)));
		END
		IF NOT EXISTS(SELECT CloseDayId FROM CloseDays WHERE StartDate = (CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))))) + '00:00:00'))
		BEGIN
			INSERT INTO CloseDays VALUES((CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))))) + '00:00:00'),(CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))))) + '23:59:59'))
		END
		IF NOT EXISTS(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))), 0) AS datetime)))))
		BEGIN
		 INSERT INTO SystemPeriods 
		 SELECT  DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))), 0) AS datetime)));
		END
		BEGIN TRANSACTION;
		UPDATE FinanceTransactions SET Isreversed=1 WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');

		INSERT INTO FinanceTransactions(Tenantid,TransactionCode,FinanceTransactionTypeId,FinanceTransactionSubTypeId,CloseDayId,ParentId,Saledescription,SaleRefence,IsOnlineSale,Isreversed,IsDeletd,AutomationRefence,Createdby,ActualDate,DateCreated)
		SELECT Tenantid, 'PAY'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),FinanceTransactionTypeId,FinanceTransactionSubTypeId, 
		(SELECT CloseDayId FROM CloseDays WHERE EndDate =(DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(CONVERT(DATE, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId'))))) AS DATETIME))))), JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId'),
		'PaymentReverse','Payment Reverse',IsOnlineSale,1,IsDeletd,AutomationRefence,JSON_VALUE(@JsonObjectdata, '$.StaffId'),ActualDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6))
		FROM FinanceTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
		SET @FinanceTransactionId = SCOPE_IDENTITY();



		INSERT INTO CustomerPayments(AgreementId,PaymentModeId,FinanceTransactionId,Amount,TransactionReference,TransactionDate,IsPaymentValidated,ChequeNo,ChequeDate,Memo,DrawerBank,DepositBank,Isactive,Isdeleted,PaidBy,SlipReference,Provider,CreatedBy,DateCreated)
		SELECT AgreementId,PaymentModeId,@FinanceTransactionId,-1*(Amount),'Payment Reverse',TransactionDate,IsPaymentValidated,ChequeNo,ChequeDate,Memo,DrawerBank,DepositBank,Isactive,Isdeleted,JSON_VALUE(@JsonObjectdata, '$.StaffId'),SlipReference,Provider,JSON_VALUE(@JsonObjectdata, '$.StaffId'), TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM CustomerPayments WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		SELECT TOP 1 @FinanceTransactionId,ChartofAccountId,(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))), 0) AS datetime))))),Currency,-1*(Amount),GlActualDate, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM GLTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');
		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		SELECT TOP 1 @FinanceTransactionId,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Receivable'),(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.StaffId')))), 0) AS datetime))))),Currency,-1*(Amount),GlActualDate, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) FROM GLTransactions WHERE FinanceTransactionId=JSON_VALUE(@JsonObjectdata, '$.FinanceTransactionId');

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
