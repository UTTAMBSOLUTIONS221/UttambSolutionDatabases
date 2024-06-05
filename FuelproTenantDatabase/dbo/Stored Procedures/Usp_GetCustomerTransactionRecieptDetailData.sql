--EXEC Usp_GetCustomerTransactionRecieptDetailData @FinanceTransactionId=77,@AccountId=5,@CustomerAccountDetailsJson=''

CREATE PROCEDURE [dbo].[Usp_GetCustomerTransactionRecieptDetailData]
    @FinanceTransactionId BIGINT,
	@AccountId BIGINT,
    @CustomerAccountDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE 
        @RespStat INT = 0,
        @RespMsg VARCHAR(150) = 'Success',
		@AccountNumber BIGINT,
		@AgreementtypeId BIGINT,
		@CustomeragreementId BIGINT,
		@Agreementtypename VARCHAR(100),
		@ConsumptionLimittypename VARCHAR(50),
		@Credittype VARCHAR(50),
		@ConsumptionPeriod VARCHAR(50),
		@BillingBasis VARCHAR(50),
		@PrepaidBfwdInPeriod DECIMAL(18,2)= 0,
		@AccountTxnSumAmount DECIMAL(18,2)= 0,
		@PostpaidLimitInPeriod DECIMAL(18,2)= 0,
		@CustomerBalance DECIMAL(18,2)= 0,
		@CustomerPostPaidLimit DECIMAL(18,2)= 0,
		@CustomerAccountBalance DECIMAL(18,2)= 0,
		@AgreementActualBalance DECIMAL(18,2)= 0,
		@AgreementBalance DECIMAL(18,2)= 0,
		@AgreementStartDate DATETIME,
		@AgreementEndDate DATETIME,
        @CurrentPeriodEndDate DATETIME,
        @PreviousPeriodEndDate DATETIME;

    BEGIN
         
			SELECT @CustomeragreementId=AG.AgreementId,@Agreementtypename=ATY.Agreementtypename,@Credittype=CTY.Credittypename,@AccountNumber=CA.AccountNumber ,@AccountId=CA.AccountId  
			FROM CustomerAccount CA 
			INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
			INNER JOIN CreditTypes CTY ON CA.CredittypeId=CTY.CredittypeId
			INNER JOIN AgreementTypes ATY ON AG.AgreemettypeId=ATY.AgreemettypeId
			INNER JOIN SystemAccountCards CAC ON CAC.AccountId = CA.AccountId 
			INNER JOIN Systemcard C ON C.CardId = CAC.CardId WHERE CAC.AccountId = @AccountId
			
			 IF(@Credittype='Prepaid')
			 BEGIN
				 SET @CurrentPeriodEndDate =DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), 0) AS datetime)));
				 SET @PreviousPeriodEndDate=DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH(dbo.getlocaldate(), -1) AS datetime))); 
				 SET @PrepaidBfwdInPeriod = (SELECT ISNULL((SELECT Bbfwd FROM ChartofAccountPeriodBalances WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=CONVERT(VARCHAR(20),@AccountNumber)) AND PeriodId=(SELECT PeriodId FROM SystemPeriods WHERE LastDateInPeriod=@PreviousPeriodEndDate)),0) AS Bbfwd)
				 SET @AccountTxnSumAmount = (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=CONVERT(VARCHAR(20),@AccountNumber)) AND PeriodId IN(SELECT PeriodId from SystemPeriods WHERE LastDateInPeriod BETWEEN @PreviousPeriodEndDate AND @CurrentPeriodEndDate)),0) AS Total)
				 --SET @CustomerAccountBalance = ((@PrepaidBfwdInPeriod) + (@AccountTxnSumAmount)) * -1;
				 SET @CustomerBalance=(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=@CustomeragreementId))),0)* -1 AS Total)
				 SET @CustomerAccountBalance =(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=CONVERT(VARCHAR(20),@AccountNumber))),0)* -1 AS Total)
			 END
			 ELSE
			 BEGIN
			   SELECT @PostpaidLimitInPeriod=ConsumptionLimit,@ConsumptionPeriod=ConsumptionPeriod,@ConsumptionLimittypename=CLT.LimitTypename FROM CustomerAccount CA INNER JOIN ConsumLimitType CLT ON CA.LimitTypeId=CLT.LimitTypeId WHERE AccountNumber = @AccountNumber
			   SET @AgreementEndDate=dbo.getlocaldate();
			   SET @AgreementStartDate= (CASE @ConsumptionPeriod
									WHEN 'Daily' THEN CAST(dbo.getlocaldate() AS DATETIME2(0)) -- For daily start
									WHEN 'Weekly' THEN CAST(DATEADD(DAY, 1 - DATEPART(WEEKDAY, dbo.getlocaldate()), CAST(dbo.getlocaldate() AS DATE)) AS DATETIME2(0)) -- For weekly start
									ELSE CAST(DATEFROMPARTS(YEAR(dbo.getlocaldate()), MONTH(dbo.getlocaldate()), 1) AS DATETIME2(0)) -- For monthly start
								END);
			   SET @AccountTxnSumAmount= (CASE @ConsumptionLimittypename WHEN 'Amount' THEN (SELECT ISNULL((SELECT SUM(GL.Amount) FROM GLTransactions GL INNER JOIN FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId WHERE GL.ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=CONVERT(VARCHAR(20),@AccountNumber)) AND GL.DateCreated BETWEEN @AgreementStartDate AND @AgreementEndDate),0) AS Total) ELSE (SELECT ISNULL((SELECT SUM(TKL.units) FROM SystemTickets TKT INNER JOIN TicketLines TKL on TKT.TicketId=TKL.ticketId INNER JOIN FinanceTransactions AS FT ON TKT.FinanceTransactionId=FT.FinanceTransactionId INNER JOIN CustomerAccount CA ON TKT.AccountId=CA.AccountId  WHERE CA.AccountNumber = @AccountNumber AND FT.ActualDate BETWEEN @AgreementStartDate AND @AgreementEndDate),0) AS Total) END);
			   SET @CustomerAccountBalance = (@PostpaidLimitInPeriod)-(@AccountTxnSumAmount);
			   IF(@Agreementtypename = 'Credit-Agreement')
			   BEGIN
			    SELECT @CustomerPostPaidLimit=CAA.CreditLimit,@ConsumptionLimittypename=CLT.LimitTypename FROM CreditAgreements CAA INNER JOIN ConsumLimitType CLT ON CAA.LimitTypeId=CLT.LimitTypeId  WHERE CAA.AgreementId = @CustomeragreementId
				SET @AgreementActualBalance=(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=@CustomeragreementId))),0)* -1 AS Total)
				SET @CustomerBalance=@CustomerPostPaidLimit- @AgreementActualBalance;
				--Check credit agreement limit
			   END
			  IF(@Agreementtypename Like '%Recurrent%')
			   BEGIN
			       SELECT @CustomerPostPaidLimit=PPRA.AllowedDebt,@AgreementBalance=PPRA.Balance, @ConsumptionLimittypename=CLT.LimitTypename,@BillingBasis=AG.BillingBasis FROM PostpaidRecurentAgreements PPRA INNER JOIN CustomerAgreements AG ON PPRA.AgreementId = AG.AgreementId INNER JOIN AgreementTypes As ATY ON AG.AgreemettypeId = ATY.AgreemettypeId INNER JOIN ConsumLimitType CLT ON ATY.LimitTypeId=CLT.LimitTypeId WHERE AG.AgreementId = @CustomeragreementId;
				   IF(@Agreementtypename = 'Recurrent-Litres-Agreement')
				   BEGIN
					SET @AgreementActualBalance=(SELECT ISNULL((SELECT SUM(TKL.Units) FROM SystemTickets TKT INNER JOIN TicketLines TKL ON TKT.TicketId=TKL.ticketId INNER JOIN TicketlinePayments PYM ON TKT.TicketId=PYM.ticketId INNER JOIN FinanceTransactions FT ON TKT.FinanceTransactionId= FT.FinanceTransactionId WHERE TKT.AccountId IN (SELECT AccountId FROM CustomerAccount WHERE AgreementId = @CustomeragreementId AND ParentId IS NOT NULL) AND FT.ActualDate BETWEEN @AgreementStartDate AND @AgreementEndDate AND pym.paymentModeId = (SELECT TOP 1 PaymentmodeId FROM PaymentModes WHERE Paymentmode = 'Card')),0) * -1 AS Total)
					SET @CustomerBalance=@CustomerPostPaidLimit- @AgreementActualBalance;
					--Check credit agreement limit
				   END
				   IF(@Agreementtypename = 'Recurrent-Amount-Agreement')
				    BEGIN
					   IF(@BillingBasis='Consumed')
						   BEGIN
							 SET @CustomerBalance=(SELECT ISNULL((SELECT SUM(PYM.TotalUsed) FROM SystemTickets TKT INNER JOIN TicketlinePayments PYM ON TKT.TicketId=PYM.ticketId INNER JOIN FinanceTransactions FT ON TKT.FinanceTransactionId= FT.FinanceTransactionId WHERE TKT.AccountId IN (SELECT AccountId FROM CustomerAccount WHERE AgreementId = @CustomeragreementId AND ParentId IS NOT NULL) AND FT.ActualDate BETWEEN @AgreementStartDate AND @AgreementEndDate AND pym.paymentModeId = (SELECT TOP 1 PaymentmodeId FROM PaymentModes WHERE Paymentmode = 'Card')),0) * -1 AS Total)
						   END
					   ELSE 
						   BEGIN
							 SET @CustomerBalance=@CustomerPostPaidLimit;
						   END
				   END
			   END
			--  IF(@Agreementtypename Like '%OneOff%' )
			--   BEGIN
			----   SELECT PPRA.AllowedDebt,PPRA.AllowedDebt,PPRA.Balance,PPRA.BillingCycleType,PPRA.BillingCycle,PPRA.GracePeriod,PPRA.StartDate,PPRA.NextBillingDate,PPRA.PreviousBillingDate,PPRA.IsActive,PPRA.IsDeleted,AT.LimitType AS LimitValueType 
			----FROM PostpaidRecurentAgreements PPRA 
			----INNER JOIN CustomerAgreements AG ON PPRA.AgreementId = AG.AgreementId 
			----INNER JOIN AgreementTypes As ATY ON AG.AgreemettypeId = ATY.AgreemettypeId WHERE AG.AgreementId = @CustomeragreementId;
 
			-- --   SELECT @CustomerPostPaidLimit=CAA.CreditLimit,@ConsumptionLimittypename=CLT.LimitTypename FROM CreditAgreements CAA INNER JOIN ConsumLimitType CLT ON CAA.LimitTypeId=CLT.LimitTypeId  WHERE CAA.AgreementId = @CustomeragreementId
			--	--SET @AgreementActualBalance=(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=@CustomeragreementId))),0)* -1 AS Total)
			--	--SET @CustomerBalance=@CustomerPostPaidLimit- @AgreementActualBalance;
			--	--Check credit agreement limit
			--   END
			 END

			 SET @CustomerAccountDetailsJson = (SELECT @RespStat as RespStatus,@RespMsg AS RespMessage,C.CustomerId,RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS CustomerName,PC.Codename  + '' +C.Phonenumber AS Phonenumber,Emailaddress AS CustomerEmail,C.DateCreated,C.IsActive AS CustomerIsActive,COALESCE(C.NoOfTransactionPerDay,0) AS NoOfTransactionPerDay,
			 COALESCE(C.AmountPerDay,0) AS AmountPerDay,COALESCE(C.ConsecutiveTransTimeMin,0) AS ConsecutiveTransTimeMin,AG.AgreementId,AG.BillingBasis,0 AS HasDriverCode,
			 CA.GroupingId,CA.AccountNumber,CT.Credittypename,CT.Credittypevalue,ATY.Agreementtypename,ATY.LimitTypeId,CLT.LimitTypename ,AG.Descriptions,(SELECT TOP 1 CurrencySymbol FROM GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId = B.CurrencyId) AS Currency,@PostpaidLimitInPeriod AS PostpaidLimitInPeriod,
			 @CustomerPostPaidLimit AS CustomerPostPaidLimit,@AgreementActualBalance AS AgreementActualBalance,
			 @CustomerBalance AS CustomerBalance,@CustomerAccountBalance AS CustomerAccountBalance,(SELECT  SUM(A.RewardAmount) FROM Lrresults A WHERE A.LRewardId=(SELECT B.LRewardId FROM LRewards B WHERE B.RewardName='Points') AND A.AccountId=@AccountId) AS CustomerPoints
			 FROM CustomerAccount CA
			 INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
			 INNER JOIN Customers C ON C.CustomerId=AG.CustomerId 
			 INNER JOIN SystemPhoneCodes PC ON C.Phoneid=PC.Phoneid
			 INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
			 INNER JOIN AgreementTypes ATY ON AG.AgreemettypeId=ATY.AgreemettypeId
			 INNER JOIN ConsumLimitType CLT ON ATY.LimitTypeId=CLT.LimitTypeId
			 WHERE CA.AccountNumber = @AccountNumber
			  FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
			)
			SELECT  @CustomerAccountDetailsJson AS Data1;	
    END;
END;