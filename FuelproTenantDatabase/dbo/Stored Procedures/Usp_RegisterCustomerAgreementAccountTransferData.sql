

CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountTransferData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @FinanceTransactionId BIGINT,
	        @Accountnumber BIGINT,
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
		BEGIN TRY	
		--Validate
		IF NOT EXISTS(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime)))))
		BEGIN
		 INSERT INTO SystemPeriods 
		 SELECT  DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime)));
		END
		IF((SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.FromAccountId')))),0) * -1)< CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TransferAmount'))))
		BEGIN
		Select  1 as RespStatus, 'Insufficient Balance!. Kindly Contact Admin' as RespMessage;
		return;
		END

		BEGIN TRANSACTION;

		--Deibit ACCOUNT TO
		INSERT INTO FinanceTransactions(TransactionCode,FinanceTransactionTypeId,FinanceTransactionSubTypeId,CloseDayId,ParentId,Saledescription,SaleRefence,AutomationRefence,Createdby,ActualDate,DateCreated)
		VALUES('TRANS'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),(select TOP 1 FinanceTransactionTypeId from FinanceTransactionTypes),(select TOP 1 FinanceTransactionSubTypeId from FinanceTransactionSubTypes),
		(SELECT  TOP 1 CloseDayId FROM CloseDays),0,JSON_VALUE(@JsonObjectdata, '$.TransactionDescription'),JSON_VALUE(@JsonObjectdata, '$.TransactionDescription'),'TRANS'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionAutmationSequence),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))

		SET @FinanceTransactionId = SCOPE_IDENTITY();

		INSERT INTO CustomerAccountTopups(FinanceTransactionId,AccountId,StationId,StaffId,ModeofPayment,Topupreference,Amount,Erprefe,Chequeno,Bankaccno,Drawerbank,Payeebank,Branchdeposited,Depositslip,Createdby,DateCreated)
		VALUES(@FinanceTransactionId,JSON_VALUE(@JsonObjectdata, '$.FromAccountId'),(SELECT TOP 1 StationId FROM LnkStaffStation WHERE UserId=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),(SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='Cash'),JSON_VALUE(@JsonObjectdata, '$.TopupReference'),-1* CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TransferAmount'))),JSON_VALUE(@JsonObjectdata, '$.TopupErpReference'),JSON_VALUE(@JsonObjectdata, '$.AccounTopupChequenumber'),JSON_VALUE(@JsonObjectdata, '$.TopupBankAccount'),JSON_VALUE(@JsonObjectdata, '$.TopupDrawerBank'),JSON_VALUE(@JsonObjectdata, '$.TopupPayeeBank'),JSON_VALUE(@JsonObjectdata, '$.TopupBranchDeposited'),JSON_VALUE(@JsonObjectdata, '$.TopupDepostiSlip'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		VALUES(@FinanceTransactionId,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.FromAccountId'))),
		(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),(select TOP 1 CurrencySymbol from GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId =B.CurrencyId), CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TransferAmount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		VALUES(@FinanceTransactionId,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Receivable'),
		(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),(select TOP 1 CurrencySymbol from GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId =B.CurrencyId), CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TransferAmount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		--Credit ACCOUNT TO
		INSERT INTO FinanceTransactions(TransactionCode,FinanceTransactionTypeId,FinanceTransactionSubTypeId,CloseDayId,ParentId,Saledescription,SaleRefence,AutomationRefence,Createdby,ActualDate,DateCreated)
		VALUES('TRANS'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),(select TOP 1 FinanceTransactionTypeId from FinanceTransactionTypes),(select TOP 1 FinanceTransactionSubTypeId from FinanceTransactionSubTypes),
		(SELECT  TOP 1 CloseDayId FROM CloseDays),0,JSON_VALUE(@JsonObjectdata, '$.TransactionDescription'),JSON_VALUE(@JsonObjectdata, '$.TransactionDescription'),'TRANS'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionAutmationSequence),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))

		SET @FinanceTransactionId = SCOPE_IDENTITY();

		INSERT INTO CustomerAccountTopups(FinanceTransactionId,AccountId,StationId,StaffId,ModeofPayment,Topupreference,Amount,Erprefe,Chequeno,Bankaccno,Drawerbank,Payeebank,Branchdeposited,Depositslip,Createdby,DateCreated)
		VALUES(@FinanceTransactionId,JSON_VALUE(@JsonObjectdata, '$.ToAccountId'),(SELECT TOP 1 StationId FROM LnkStaffStation WHERE UserId=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),(SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='Cash'),JSON_VALUE(@JsonObjectdata, '$.TopupReference'), CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TransferAmount'))),JSON_VALUE(@JsonObjectdata, '$.TopupErpReference'),JSON_VALUE(@JsonObjectdata, '$.AccounTopupChequenumber'),JSON_VALUE(@JsonObjectdata, '$.TopupBankAccount'),JSON_VALUE(@JsonObjectdata, '$.TopupDrawerBank'),JSON_VALUE(@JsonObjectdata, '$.TopupPayeeBank'),JSON_VALUE(@JsonObjectdata, '$.TopupBranchDeposited'),JSON_VALUE(@JsonObjectdata, '$.TopupDepostiSlip'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		VALUES(@FinanceTransactionId,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.ToAccountId'))),
		(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),(select TOP 1 CurrencySymbol from GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId =B.CurrencyId),-1 * CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TransferAmount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		VALUES(@FinanceTransactionId,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Receivable'),
		(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),(select TOP 1 CurrencySymbol from GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId =B.CurrencyId),-1 * CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TransferAmount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))



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