

CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementPaymentData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @FinanceTransactionId BIGINT,
	        @Accountnumber BIGINT,
			@CustomerPaymentId BIGINT,
			@Agreementtypename VARCHAR(100),
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
		BEGIN TRY	
		--Validate
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
		 SET @Agreementtypename=(SELECT Agreementtypename FROM CustomerAgreements INNER JOIN AgreementTypes ON CustomerAgreements.AgreemettypeId=AgreementTypes.AgreemettypeId WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId'));
			

		INSERT INTO FinanceTransactions(TransactionCode,FinanceTransactionTypeId,FinanceTransactionSubTypeId,CloseDayId,ParentId,Saledescription,SaleRefence,AutomationRefence,Createdby,ActualDate,DateCreated)
		VALUES('PAY'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),(select TOP 1 FinanceTransactionTypeId from FinanceTransactionTypes),(select TOP 1 FinanceTransactionSubTypeId from FinanceTransactionSubTypes),
		(SELECT  TOP 1 CloseDayId FROM CloseDays),0,'Payment',JSON_VALUE(@JsonObjectdata, '$.TransactionReference'),'PAY'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionAutmationSequence),
		JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),
		TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)),
		TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2(6)))

		SET @FinanceTransactionId = SCOPE_IDENTITY();

		INSERT INTO CustomerPayments(AgreementId,PaymentModeId,FinanceTransactionId,Amount,TransactionReference,TransactionDate,IsPaymentValidated,ChequeNo,ChequeDate,Memo,DrawerBank,DepositBank,Isactive,Isdeleted,PaidBy,SlipReference,Provider,CreatedBy,DateCreated)
		VALUES(JSON_VALUE(@JsonObjectdata, '$.AgreementId'),JSON_VALUE(@JsonObjectdata, '$.PaymentModeId'),@FinanceTransactionId,JSON_VALUE(@JsonObjectdata, '$.Amount'),JSON_VALUE(@JsonObjectdata, '$.TransactionReference'),JSON_VALUE(@JsonObjectdata, '$.TransactionDate'),1,
		JSON_VALUE(@JsonObjectdata, '$.ChequeNo'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),JSON_VALUE(@JsonObjectdata, '$.Memo'),JSON_VALUE(@JsonObjectdata, '$.DrawerBank'),JSON_VALUE(@JsonObjectdata, '$.DepositBank'),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.SlipReference'),JSON_VALUE(@JsonObjectdata, '$.Provider'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2))


		SET @CustomerPaymentId = SCOPE_IDENTITY();


		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		VALUES(@FinanceTransactionId,
		(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE ParentId=0 AND  AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId'))),
		(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),(select TOP 1 CurrencySymbol from GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId =B.CurrencyId),-1 * CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.Amount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2))

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
		VALUES(@FinanceTransactionId,
		(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Receivable'),
		(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime))))),(select TOP 1 CurrencySymbol from GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId =B.CurrencyId),-1 * CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.Amount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2))

		IF(@Agreementtypename='Credit-Agreement')
		BEGIN 
		DECLARE @RemainingAmount DECIMAL = JSON_VALUE(@JsonObjectdata, '$.Amount');
		DECLARE @CurrentInvoiceID INT,@CurrentInvoiceAmount DECIMAL;
		DECLARE InvoiceCursor CURSOR FOR
		SELECT CI.InvoiceId, CI.Balance AS RemainingAmountToPay FROM CreditInvoices CI WHERE
			CI.CreditAgreementId = (SELECT CreditAgreementId FROM CreditAgreements WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId')) AND CI.IsPaid = 0 ORDER BY CI.DueDate;

		OPEN InvoiceCursor;

		FETCH NEXT FROM InvoiceCursor INTO @CurrentInvoiceID, @CurrentInvoiceAmount;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @RemainingAmount >= @CurrentInvoiceAmount
			BEGIN
			 UPDATE CreditInvoices SET IsPaid =1,PayStatus='PAID', PaidAmount=@CurrentInvoiceAmount,Balance=0 WHERE InvoiceId =@CurrentInvoiceID
		      
			  INSERT INTO Invoicesettlement(PaymentId,InvoiceId,Amountused,Datesettled)
			  SELECT @CustomerPaymentId,@CurrentInvoiceID,@CurrentInvoiceAmount,dbo.GetLocalDate()
				-- Update the remaining amount
				SET @RemainingAmount = @RemainingAmount - @CurrentInvoiceAmount;
			END
			ELSE
			BEGIN
			  UPDATE CreditInvoices SET IsPaid =0,PayStatus='Partially Paid',PaidAmount=PaidAmount+@RemainingAmount,Balance=Balance-@RemainingAmount WHERE InvoiceId=@CurrentInvoiceID

			  INSERT INTO Invoicesettlement(PaymentId,InvoiceId,Amountused,Datesettled)
			  SELECT @CustomerPaymentId,@CurrentInvoiceID,@CurrentInvoiceAmount,dbo.GetLocalDate()

				-- Exit the loop as payment is exhausted
				BREAK;
			END;

			FETCH NEXT FROM InvoiceCursor INTO @CurrentInvoiceID, @CurrentInvoiceAmount;
		END;

		CLOSE InvoiceCursor;
		DEALLOCATE InvoiceCursor;
		END


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