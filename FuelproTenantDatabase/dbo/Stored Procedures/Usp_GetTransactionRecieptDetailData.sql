--EXEC Usp_GetTransactionRecieptDetailData @FinanceTransactionId=26,@FinanceTransactionDetailsJson=''

CREATE PROCEDURE [dbo].[Usp_GetTransactionRecieptDetailData]
    @FinanceTransactionId BIGINT,
	@AccountId BIGINT,
    @FinanceTransactionDetailsJson VARCHAR(MAX) OUTPUT
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
			IF(@AccountId>0)
			BEGIN
			   SELECT @CustomeragreementId=AG.AgreementId,@Agreementtypename=ATY.Agreementtypename,@Credittype=CTY.Credittypename,@AccountNumber=CA.AccountNumber  
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
        
					 SET @FinanceTransactionDetailsJson = (SELECT @RespStat as RespStatus,@RespMsg AS RespMessage,A.TransactionCode,A.TransactionCode +''+CONVERT(VARCHAR(10),A.FinanceTransactionId) AS TransactionRefenece,
						A.Saledescription,CASE WHEN H.Designation='Corporate' THEN H.Companyname ELSE H.Firstname+' '+ H.Lastname END AS Customername,H.Emailaddress,
						D.CardSNO AS CustomerCard,D.CardCode,I.Agreementtypename,E.Sname AS StationName,K.TotalUsed AS SubTotal,K.TotalUsed AS Total,K.TotalUsed AS NetTotal,K.TotalUsed AS FuelProCard,@CustomerBalance AS CustomerBalance,@CustomerAccountBalance AS CardBalance,
						ISNULL((SELECT ISNULL(LR.RewardName,'N/A') FROM LRADataInputs V INNER JOIN LRResults W ON V.LRADataInputId=W.LRADataInputId INNER JOIN LRewards LR ON W.LRewardId=LR.LRewardId WHERE V.FinanceTransactionId=A.FinanceTransactionId),'N/A') AS RewardName,
						ISNULL((SELECT ISNULL(W.RewardAmount,0) FROM LRADataInputs V INNER JOIN LRResults W ON V.LRADataInputId=W.LRADataInputId WHERE V.FinanceTransactionId=A.FinanceTransactionId),0) AS CurrentPoints,
						(SELECT ISNULL(SUM(W.RewardAmount),0) FROM LRResults W WHERE W.AccountId=C.AccountId) AS CumulativePoints,
						J.Groupingname,A.SaleRefence,A.ActualDate,A.DateCreated,B.StaffId,L.Fullname AS Attendantname,U.Paymentmode,
						(
							 SELECT BB.Productvariationname,AA.Units,AA.Price,AA.Discount, CC.TotalUsed AS SaleAmount 
							 FROM Ticketlines AA 
							 INNER JOIN SystemProductvariation BB ON AA.ProductvariationId=BB.ProductvariationId
							 INNER JOIN  TicketlinePayments CC ON AA.TicketId=CC.TicketId
							 WHERE AA.TicketId=B.TicketId
							FOR JSON PATH
						) AS Ticketlines
						FROM FinanceTransactions A
						INNER JOIN SystemTickets B ON A.FinancetransactionId=B.FinancetransactionId
						INNER JOIN TicketlinePayments K ON B.TicketId=K.TicketId
						 INNER JOIN Paymentmodes U ON K.PaymentmodeId=U.PaymentmodeId
						INNER JOIN SystemStations E ON B.StationId=E.Tenantstationid
						INNER JOIN SystemAccountCards C ON B.AccountId=C.AccountId
						INNER JOIN Systemcard D ON C.CardId=D.CardId
						INNER JOIN CustomerAccount F ON C.AccountId=F.AccountId
						INNER JOIN CustomerAgreements G ON F.AgreementId=G.AgreementId
						INNER JOIN AgreementTypes I ON G.AgreemettypeId=I.AgreemettypeId
						INNER JOIN Customers H ON G.CustomerId=H.CustomerId
						INNER JOIN LoyaltyGroupings J ON F.GroupingId=J.GroupingId
						INNER JOIN SystemStaffs L ON B.StaffId=L.UserId
						WHERE A.FinanceTransactionId=@FinanceTransactionId
					  FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
					)
			END
			ELSE
			BEGIN
			     SET @FinanceTransactionDetailsJson = (SELECT @RespStat as RespStatus,@RespMsg AS RespMessage,A.TransactionCode,A.TransactionCode +''+CONVERT(VARCHAR(10),A.FinanceTransactionId) AS TransactionRefenece,
						A.Saledescription,CASE WHEN H.Designation='Corporate' THEN H.Companyname ELSE H.Firstname+' '+ H.Lastname END AS Customername,H.Emailaddress,
						D.CardSNO AS CustomerCard,D.CardCode,I.Agreementtypename,E.Sname AS StationName,K.TotalUsed AS SubTotal,K.TotalUsed AS Total,K.TotalUsed AS NetTotal,K.TotalUsed AS FuelProCard,0 AS CustomerBalance,0 AS CardBalance,
						ISNULL((SELECT ISNULL(LR.RewardName,'N/A') FROM LRADataInputs V INNER JOIN LRResults W ON V.LRADataInputId=W.LRADataInputId INNER JOIN LRewards LR ON W.LRewardId=LR.LRewardId WHERE V.FinanceTransactionId=A.FinanceTransactionId),'N/A') AS RewardName,
						ISNULL((SELECT ISNULL(W.RewardAmount,0) FROM LRADataInputs V INNER JOIN LRResults W ON V.LRADataInputId=W.LRADataInputId WHERE V.FinanceTransactionId=A.FinanceTransactionId),0) AS CurrentPoints,
						(SELECT ISNULL(SUM(W.RewardAmount),0) FROM LRResults W WHERE W.AccountId=C.AccountId) AS CumulativePoints,
						J.Groupingname,A.SaleRefence,A.ActualDate,A.DateCreated,B.StaffId,L.Fullname AS Attendantname,U.Paymentmode,
						(
							 SELECT BB.Productvariationname,AA.Units,AA.Price,AA.Discount, CC.TotalUsed AS SaleAmount 
							 FROM Ticketlines AA 
							 INNER JOIN SystemProductvariation BB ON AA.ProductvariationId=BB.ProductvariationId
							 INNER JOIN  TicketlinePayments CC ON AA.TicketId=CC.TicketId
							 WHERE AA.TicketId=B.TicketId
							FOR JSON PATH
						) AS Ticketlines
						FROM FinanceTransactions A
						LEFT JOIN SystemTickets B ON A.FinancetransactionId=B.FinancetransactionId
						LEFT JOIN TicketlinePayments K ON B.TicketId=K.TicketId
						LEFT JOIN Paymentmodes U ON K.PaymentmodeId=U.PaymentmodeId
						LEFT JOIN SystemStations E ON B.StationId=E.Tenantstationid
						LEFT JOIN SystemAccountCards C ON B.AccountId=C.AccountId
						LEFT JOIN Systemcard D ON C.CardId=D.CardId
						LEFT JOIN CustomerAccount F ON C.AccountId=F.AccountId
						LEFT JOIN CustomerAgreements G ON F.AgreementId=G.AgreementId
						LEFT JOIN AgreementTypes I ON G.AgreemettypeId=I.AgreemettypeId
						LEFT JOIN Customers H ON G.CustomerId=H.CustomerId
						LEFT JOIN LoyaltyGroupings J ON F.GroupingId=J.GroupingId
						LEFT JOIN SystemStaffs L ON B.StaffId=L.UserId
						WHERE A.FinanceTransactionId=@FinanceTransactionId
					  FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
					)
			END
			SELECT  @FinanceTransactionDetailsJson AS FinanceTransactionDetailsJson;	
    END;
END;