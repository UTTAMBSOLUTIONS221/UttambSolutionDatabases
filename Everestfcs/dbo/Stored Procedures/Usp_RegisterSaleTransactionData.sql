CREATE PROCEDURE [dbo].[Usp_RegisterSaleTransactionData]
@JsonObjectdata VARCHAR(MAX),
@FinanceTransactionDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Agreementtypename VARCHAR(100),
			@FinanceTransactionId BIGINT,
			@TicketId BIGINT,
			@AutomationReference VARCHAR(70),
		    @TransactionReference VARCHAR(40),
			@TransactionDescription VARCHAR(20),
			@TransactionRewardAmount DECIMAL(34,2)= 0,
			@AccountId BIGINT,
			@LraDataInputId BIGINT,
			@AmountBeingSpent  DECIMAL(34,2)= 0,
			@QuantitySpent  DECIMAL(34,2)= 0,
			@RecurrentAllowedDebt  DECIMAL(34,2)= 0,
			@TotalRewardAmount DECIMAL(34,2)= 0,
			@RedeemConvertionvalue DECIMAL(34,2)= 0,
			@FirstDateofMonth  DATETIME,
			@EndDateofMonth  DATETIME,
			@LimitValueType VARCHAR(100),
			@BillingBasis VARCHAR(100);
	BEGIN
		BEGIN TRY	
		--Validate
		--validate customer details
		IF EXISTS(SELECT CardId FROM Systemcard WHERE CardUID=JSON_VALUE(@JsonObjectdata, '$.CardUID')  AND IsActive=0 )
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Card/Mask Marked as Inactive cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		 IF EXISTS(SELECT CardId FROM Systemcard WHERE CardUID=JSON_VALUE(@JsonObjectdata, '$.CardUID') AND IsReplaced=1)
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Card/Mask Marked as Replaced cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		 IF EXISTS(SELECT CardId FROM Systemcard WHERE CardUID=JSON_VALUE(@JsonObjectdata, '$.CardUID')  AND IsDeleted=1 )
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Card/Mask Marked as Deleted cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		IF EXISTS(SELECT AccountId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') AND IsActive= 0)
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Card/Mask Marked as Inactive cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		 IF EXISTS(SELECT AccountId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') AND IsDeleted= 1)
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Card/Mask Marked as Deleted cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		IF EXISTS(SELECT AgreementId FROM CustomerAgreements WHERE AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')) AND IsActive= 0)
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Customer Agreement Marked as Inactive cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		 IF EXISTS(SELECT AgreementId FROM CustomerAgreements WHERE AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')) AND IsDeleted= 1)
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Customer Agreement  Marked as Deleted cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		IF EXISTS(SELECT CustomerId FROM Customers WHERE CustomerId =(SELECT CustomerId FROM CustomerAgreements WHERE AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))) AND IsActive= 0)
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Customer Marked as Inactive cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		 IF EXISTS(SELECT CustomerId FROM Customers WHERE CustomerId =(SELECT CustomerId FROM CustomerAgreements WHERE AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))) AND IsDeleted= 1)
		 BEGIN 
		     SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Customer Marked as Deleted cannot transact!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			 return;
		 END
		 --check policies violation

		 --IF NOT EXISTS(SELECT ProductVariationId FROM AccountProducts WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') AND ProductVariationId  IN (SELECT ProductVariationId FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationId BIGINT)))
		 --BEGIN 
			-- Select  1 as RespStatus, 'Wrong Product for Account!. Kindly Contact Admin' as RespMessage;
			-- return;
		 --END
		 --IF NOT EXISTS(SELECT StationId FROM AccountStations WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') AND StationId=JSON_VALUE(@JsonObjectdata, '$.StationId'))
		 --BEGIN 
			-- Select  1 as RespStatus, 'Wrong Station for Account!. Kindly Contact Admin' as RespMessage;
			-- return;
		 --END
		 --IF NOT EXISTS(SELECT AccountWeekDaysId FROM AccountWeekDays WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') AND WeekDays IN(DATEPART(dw, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))))
		 --BEGIN 
			-- Select  1 as RespStatus, 'Wrong Week day for Account!. Kindly Contact Admin' as RespMessage;
			-- return;
		 --END
		 --IF NOT EXISTS(SELECT id FROM AccountTransactionFrequency WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') AND WeekDays IN(DATEPART(dw, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))))
		 --BEGIN 
			-- Select  1 as RespStatus, 'Wrong Week day for Account!. Kindly Contact Admin' as RespMessage;
			-- return;
		 --END

		 IF((SELECT PaymentModeId FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (PaymentModeId BIGINT)) IN (SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='Card'))
	     BEGIN
			 SET @Agreementtypename=(SELECT Agreementtypename FROM CustomerAgreements INNER JOIN AgreementTypes ON CustomerAgreements.AgreemettypeId=AgreementTypes.AgreemettypeId WHERE AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')));
			 SET @AmountBeingSpent=(SELECT TotalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (PaymentModeId BIGINT, TotalPaid DECIMAL(18,2), TotalUsed DECIMAL(18,2), MpesaCode VARCHAR(50), MpesaMSISDN VARCHAR(50), DateCreated DATETIME2(6)));
			 SET @QuantitySpent=(SELECT SUM(productvariationUnits) FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductvariationUnits  DECIMAL(18,2)));
			 IF(@Agreementtypename='Prepaid-Agreement')
			 BEGIN
				  --check Account balance
				  IF((SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))),0) * -1)<@AmountBeingSpent)
				  BEGIN
				   SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Insufficient Account Balance!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
				   return;
				  END
				 --check customer balance
				  IF((SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),0)* -1)<@AmountBeingSpent)
				  BEGIN
				   SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Insufficient Customer Balance!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
				   return;
				  END
			  END
			 ELSE IF(@Agreementtypename='Credit-Agreement')
			 BEGIN
			    --check customer Limit
				  IF((SELECT CreditLimit + AllowedCredit FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId')))<@AmountBeingSpent)
				  BEGIN
				   SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Credit Limit Exceeded!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
				   return;
				  END
				  IF((SELECT COUNT(InvoiceId) FROM CreditInvoices WHERE CreditAgreementId =(SELECT CreditAgreementId FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))) AND IsPaid=0 AND (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))>=DueDate)>0)
				   BEGIN
				    SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Due Invoice Available!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
				    return;
				  END
			 END
			 ELSE IF(@Agreementtypename='Recurrent-Amount-Agreement' OR @Agreementtypename='Recurrent-Litres-Agreement')
			 BEGIN
			  SET @FirstDateofMonth=(SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))), 0));
			  SET @EndDateofMonth=(SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))) + 1, 0));
			  SELECT @LimitValueType=C.LimitTypename,@BillingBasis=A.BillingBasis,@RecurrentAllowedDebt=D.AllowedDebt FROM CustomerAgreements A INNER JOIN AgreementTypes B ON A.AgreemettypeId=b.AgreemettypeId INNER JOIN ConsumLimitType C ON B.LimitTypeId=C.LimitTypeId INNER JOIN PostpaidRecurentAgreements D ON A.AgreementId=D.AgreementId WHERE A.AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'));
			  IF(@LimitValueType='Amount')
			  BEGIN 
			    IF((@RecurrentAllowedDebt-(SELECT ISNULL((SELECT SUM(CAST(amount as decimal(18,2))) FROM GLTransactions GL INNER JOIN  FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId WHERE FT.Saledescription in('Sale','SaleReverse') AND ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId = (SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId')) AND FT.ActualDate >= (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))), 0))))),0))) < @AmountBeingSpent)
				BEGIN
				    SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Limit Will be Exceeded!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
				    return;
				END
			  END
			  ELSE
			  BEGIN
			    IF((@RecurrentAllowedDebt-(SELECT ISNULL((SELECT SUM(CAST(TKL.Units as decimal(18,2))) FROM GLTransactions GL INNER JOIN  FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId INNER JOIN SystemTickets TKT ON TKT.FinanceTransactionId=FT.FinanceTransactionId INNER JOIN Ticketlines TKL ON TKL.TicketId=TKT.TicketId WHERE FT.Saledescription in('Sale','SaleReverse') AND ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId = (SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId')) AND FT.ActualDate >= (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))), 0))))),0))) < @QuantitySpent)
				BEGIN
				  SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Limit Will be Exceeded!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
				  return;
				END
			  END
			 END
			 
			 --ELSE IF(@Agreementtypename='OneOff-Amount-Agreement')
			 --BEGIN
			 --END
			 --ELSE IF(@Agreementtypename='OneOff-Litres-Agreement')
			 --BEGIN
			 --END

		 END
		ELSE If((SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='IVoucher') IN (SELECT paymentModeId FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (PaymentModeId BIGINT)))
		 BEGIN
			IF((SELECT TotalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2)))*(SELECT CASE WHEN AutoRedeem=0 THEN ConversionValue ELSE 0 END FROM LoyaltySettings  WHERE FromRewardId=(SELECT LRewardId FROM LRewards WHERE RewardName='Points') AND ToRewardId =(SELECT LRewardId FROM LRewards WHERE RewardName='Discount Voucher') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))>(SELECT SUM(LR.RewardAmount) FROM LRResults LR  WHERE LR.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))
			BEGIN
			SET @FinanceTransactionDetailsJson = (Select  1 as RespStatus, 'Insufficient Redeemable Points!. Kindly Contact Admin' as RespMessage   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
			return;
			END
		 END
	    IF (@AutomationReference IS NULL OR @AutomationReference=0)
		BEGIN
		 SET @AutomationReference='AUT'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionAutmationSequence)
		END
		IF NOT EXISTS(SELECT CloseDayId FROM CloseDays WHERE StartDate = (CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))))) + '00:00:00'))
		BEGIN
		 INSERT INTO CloseDays VALUES((CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))))) + '00:00:00'),(CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))))) + '23:59:59'))
		END
		IF NOT EXISTS(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))), 0) AS datetime)))))
		BEGIN
		 INSERT INTO SystemPeriods(Lastdateinperiod) 
		 SELECT  DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))), 0) AS datetime)));
		END
		BEGIN TRANSACTION;
		INSERT INTO FinanceTransactions(Tenantid,TransactionCode,FinanceTransactionTypeId,FinanceTransactionSubTypeId,CloseDayId,ParentId,Saledescription,SaleRefence,IsOnlineSale,AutomationRefence,Createdby,ActualDate,DateCreated)
		VALUES(JSON_VALUE(@JsonObjectdata, '$.TenantId'),'TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),(select TOP 1 FinanceTransactionTypeId from FinanceTransactionTypes),(select TOP 1 FinanceTransactionSubTypeId from FinanceTransactionSubTypes),
		(SELECT CloseDayId FROM CloseDays WHERE EndDate =(DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(CONVERT(DATE, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))) AS DATETIME))))),0,'Sale',JSON_VALUE(@JsonObjectdata, '$.SaleReference'),JSON_VALUE(@JsonObjectdata, '$.IsSaleOnline'),@AutomationReference,
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
		DATEADD(MILLISECOND,DATEPART(MILLISECOND, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),DATEADD(second, DATEPART(second, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))), TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))),
		TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))

		SET @FinanceTransactionId = SCOPE_IDENTITY();

		 If((SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='Card') IN (SELECT paymentModeId FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (PaymentModeId BIGINT)))
		 BEGIN
			INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
			VALUES(@FinanceTransactionId,
			(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))),
			(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))), 0) AS datetime))))),(SELECT TOP 1 e.Currencyname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')),JSON_VALUE(@JsonObjectdata, '$.TotalMoneySold'),	DATEADD(MILLISECOND,DATEPART(MILLISECOND, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),DATEADD(second, DATEPART(second, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))), TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
			INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
			VALUES(@FinanceTransactionId,
			(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Payable'),
			(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')))), 0) AS datetime))))),(SELECT TOP 1 e.Currencyname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')),JSON_VALUE(@JsonObjectdata, '$.TotalMoneySold'),	DATEADD(MILLISECOND,DATEPART(MILLISECOND, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),DATEADD(second, DATEPART(second, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))), TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
			IF(@Agreementtypename='Credit-Agreement')
			BEGIN 
			    IF((SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),0)* -1)>=@AmountBeingSpent)
				BEGIN
				 INSERT INTO CreditInvoices(InvoiceNo,CreditAgreementId,FinanceTransactionId,TransactionDate,PostingDate,DueDate,AccountId,Amount,Discount,ProductVariationId,Units,Price,IsPaid,PaidAmount,PayStatus,Balance,IsReversed,IsActive,IsDeleted,IsOverConsumption,CreatedBy,DateCreated)
				 (SELECT 'INV'+''+dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID),(SELECT CreditAgreementtId FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))),@FinanceTransactionId,
				 TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),DATEADD(DAY,(SELECT Paymentterms FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6))),
				 JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT totalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2))),(SELECT ProductVariationDiscount FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationDiscount DECIMAL(18,2))),(SELECT ProductVariationId FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationId BIGINT)),(SELECT ProductvariationUnits FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductvariationUnits DECIMAL(18,2))),(SELECT productVariationPrice FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationPrice DECIMAL(18,2))),
				 1,(SELECT totalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2))),'PAID',0,0,1,0,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
				END
				ELSE IF((SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),0)* -1)>0 AND (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),0)* -1)<@AmountBeingSpent)
				BEGIN
				INSERT INTO CreditInvoices(InvoiceNo,CreditAgreementId,FinanceTransactionId,TransactionDate,PostingDate,DueDate,AccountId,Amount,Discount,ProductVariationId,Units,Price,IsPaid,PaidAmount,PayStatus,Balance,IsReversed,IsActive,IsDeleted,IsOverConsumption,CreatedBy,DateCreated)
				 (SELECT 'INV'+''+dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID),(SELECT CreditAgreementtId FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))),@FinanceTransactionId,
				 TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),DATEADD(DAY,(SELECT Paymentterms FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6))),
				 JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT totalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2))),(SELECT ProductVariationDiscount FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationDiscount DECIMAL(18,2))),(SELECT ProductVariationId FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationId BIGINT)),(SELECT ProductvariationUnits FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductvariationUnits DECIMAL(18,2))),(SELECT productVariationPrice FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationPrice DECIMAL(18,2))),
				 0,(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),0)* -1),'PARTIALLY PAID',((SELECT totalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2)))-(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=(SELECT AgreementId FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),0)* -1)),0,1,0,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
				END
				ELSE
				BEGIN
				 INSERT INTO CreditInvoices(InvoiceNo,CreditAgreementId,FinanceTransactionId,TransactionDate,PostingDate,DueDate,AccountId,Amount,Discount,ProductVariationId,Units,Price,IsPaid,PaidAmount,PayStatus,Balance,IsReversed,IsActive,IsDeleted,IsOverConsumption,CreatedBy,DateCreated)
				 (SELECT 'INV'+''+dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID),(SELECT CreditAgreementtId FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))),@FinanceTransactionId,
				 TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),DATEADD(DAY,(SELECT Paymentterms FROM CreditAgreements WHERE AgreementId=(SELECT CA.AgreementId FROM CustomerAccount CA WHERE CA.AccountId =JSON_VALUE(@JsonObjectdata, '$.AccountId'))),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6))),
				 JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT totalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2))),(SELECT ProductVariationDiscount FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationDiscount DECIMAL(18,2))),(SELECT ProductVariationId FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationId BIGINT)),(SELECT ProductvariationUnits FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductvariationUnits DECIMAL(18,2))),(SELECT productVariationPrice FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationPrice DECIMAL(18,2))),
				 0,0,'NOT PAID',(SELECT totalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2))),0,1,0,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
				END
				
			END
		END
		 

		 If((SELECT PaymentmodeId FROM Paymentmodes WHERE Paymentmode='IVoucher') IN (SELECT paymentModeId FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (PaymentModeId BIGINT)))
		 BEGIN
		    SET @RedeemConvertionvalue=(SELECT CASE WHEN AutoRedeem=0 THEN ConversionValue ELSE 0 END FROM LoyaltySettings  WHERE FromRewardId=(SELECT LRewardId FROM LRewards WHERE RewardName='Points') AND ToRewardId =(SELECT LRewardId FROM LRewards WHERE RewardName='Discount Voucher') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))
			
			INSERT INTO LRConversionDataInputs(FinanceTransactionId,FromReward,ToReward,StationId,AccountNumber,StaffId,IsProcessed,DateCreated,ConvertToAmount,Comments)
			(SELECT @FinanceTransactionId,(SELECT LRewardId FROM LRewards WHERE RewardName='Points'),(SELECT LRewardId FROM LRewards WHERE RewardName='Discount Voucher'),JSON_VALUE(@JsonObjectdata, '$.StationId'),JSON_VALUE(@JsonObjectdata, '$.AccountId'),JSON_VALUE(@JsonObjectdata, '$.Userid'),1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)),
			((SELECT TotalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2)))*@RedeemConvertionvalue),JSON_VALUE(@JsonObjectdata, '$.SaleReference'))
			SET @LraDataInputId = SCOPE_IDENTITY();
			--Redeeming Points
			 INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
		     VALUES (JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT LrewardId FROM Lrewards WHERE RewardName = 'Points'),(SELECT LtransactionTypeId FROM LtransactionTypes WHERE LtransactionTypeName = 'Redeem'),
				   0,@LraDataInputId,-1*((SELECT TotalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2))) * @RedeemConvertionvalue),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
            --Converting points to Discount Voucher
			INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
		     VALUES (JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT LrewardId FROM Lrewards WHERE RewardName = 'Discount Voucher'),(SELECT LtransactionTypeId FROM LtransactionTypes WHERE LtransactionTypeName = 'Conversion'),
				   0,@LraDataInputId,-1*((SELECT TotalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2)))),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
		--Utizie Discount Voucher
			INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
		     VALUES (JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT LrewardId FROM Lrewards WHERE RewardName = 'Discount Voucher'),(SELECT LtransactionTypeId FROM LtransactionTypes WHERE LtransactionTypeName = 'RewardUtilization'),
				   0,@LraDataInputId,((SELECT TotalUsed FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (TotalUsed  DECIMAL(18,2)))),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))

		 END

		 
		 
		 
		 INSERT INTO SystemTickets(FinanceTransactionId,StaffId,StationId,AccountId,Createdby,ActualDate,DateCreated)
		 (SELECT @FinanceTransactionId,JSON_VALUE(@JsonObjectdata, '$.Userid'),JSON_VALUE(@JsonObjectdata, '$.StationId'),JSON_VALUE(@JsonObjectdata, '$.AccountId'),
		 JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),DATEADD(MILLISECOND,DATEPART(MILLISECOND, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))),DATEADD(second, DATEPART(second, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))))), TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))),
		TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)));

		 SET @TicketId = SCOPE_IDENTITY();


		INSERT INTO Ticketlines (TicketId, productVariationId, Units, Price,Discount,Createdby,DateCreated)
		SELECT @TicketId, ProductVariationId,productvariationUnits,productVariationPrice,ProductVariationDiscount,CreatedbyId,DateCreated FROM OPENJSON (@JsonObjectdata, '$.TicketLines')
		WITH (ProductVariationId BIGINT,ProductvariationUnits  DECIMAL(18,2),ProductVariationPrice DECIMAL(18,2),ProductVariationDiscount DECIMAL(18,2),CreatedbyId BIGINT,DateCreated DATETIME2(6))

		INSERT INTO TicketlinePayments (TicketId, PaymentmodeId, TotalPaid, TotalUsed, mpesaCode, mpesaMSISDN,DateCreated)
	    SELECT @TicketId, paymentModeId,totalPaid,totalUsed,mpesaCode,mpesaMSISDN,DateCreated FROM OPENJSON (@JsonObjectdata, '$.PaymentList')
	    WITH (PaymentModeId BIGINT,TotalPaid  DECIMAL(18,2),TotalUsed  DECIMAL(18,2),MpesaCode VARCHAR(50),MpesaMSISDN VARCHAR(50),DateCreated DATETIME2(6))
		
	

		IF(JSON_VALUE(@JsonObjectdata, '$.CustomerVehicleId')>0)
		BEGIN
		  INSERT INTO CustomerVehicleUsages(Odometer,EquipmentId,TicketId,DateCreated)
		  SELECT JSON_VALUE(@JsonObjectdata, '$.OdometerReading'),JSON_VALUE(@JsonObjectdata, '$.CustomerVehicleId'),@TicketId,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)) 
		END
		SET @AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId');
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		 DECLARE @ResultTable TABLE (RespStatus INT,RespMessage VARCHAR(150));
		 INSERT INTO @ResultTable   EXEC Usp_CheckIfSaleTransactionQualify @JsonObjectdata,@FinanceTransactionId=@FinanceTransactionId;
	
		DECLARE @ResultTable1 TABLE (FinanceTransactionDetailsJson VARCHAR(MAX));
		INSERT INTO @ResultTable1 EXEC Usp_GetTransactionRecieptDetailData @FinanceTransactionId=@FinanceTransactionId,@AccountId=@AccountId,@FinanceTransactionDetailsJson = @FinanceTransactionDetailsJson OUTPUT;
		SELECT  * FROM @ResultTable1 AS FinanceTransactionDetailsJson 
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
