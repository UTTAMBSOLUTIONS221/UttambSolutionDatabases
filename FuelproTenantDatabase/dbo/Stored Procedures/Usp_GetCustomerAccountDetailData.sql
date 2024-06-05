
--EXEC Usp_GetCustomerAccountDetailData @AccountId=8,@CustomerAccountDetailsJson=''

CREATE PROCEDURE [dbo].[Usp_GetCustomerAccountDetailData]
	@AccountId BIGINT,
	@CustomerAccountDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN
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
	
		BEGIN TRY

		BEGIN TRANSACTION;
		SET @CurrentPeriodEndDate =(SELECT  DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)));
		SET @PreviousPeriodEndDate =(SELECT DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)));
		SELECT @CustomeragreementId=AG.AgreementId,@Agreementtypename=ATY.Agreementtypename,@Credittype=CTY.Credittypename,@AccountNumber=CA.AccountNumber  
			FROM CustomerAccount CA 
			INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
			INNER JOIN CreditTypes CTY ON CA.CredittypeId=CTY.CredittypeId
			INNER JOIN AgreementTypes ATY ON AG.AgreemettypeId=ATY.AgreemettypeId
			INNER JOIN SystemAccountCards CAC ON CAC.AccountId = CA.AccountId WHERE CAC.AccountId = @AccountId
			
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
		
		SET @CustomerAccountDetailsJson= (
		SELECT
		C.CustomerId,A.AccountId,CASE WHEN C.Designation='Corporate' THEN C.Companyname ELSE C.Firstname+' '+ C.Lastname END AS Customername,C.Emailaddress,A.AccountNumber,I.CardSNO,I.CardUID,A.ConsumptionLimit,(SELECT TOP 1 CurrencySymbol FROM GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId =B.CurrencyId) AS Currency,
		A.GroupingId,D.Groupingname AS LoyaltyGroupingName,A.CredittypeId,E.Credittypename,A.ConsumptionPeriod,G.Agreementtypename,F.LimitTypename,
		@CustomerBalance AS CustomerBalance,(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=(SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=B.AgreementId AND CA.ParentId=0 AND CA.IsActive=1 AND CA.IsDeleted=0))),0)* -1) AS AgreementBalance,
		@CustomerAccountBalance AS AccountBalance,
		(
		  SELECT aa.AccountTopupId,aa.FinanceTransactionId,ee.TransactionCode,ee.Saledescription,ee.SaleRefence,ee.Isreversed,aa.AccountId,aa.StationId,bb.Sname AS StationName,aa.ModeofPayment,cc.Paymentmode,aa.Topupreference,aa.Amount,aa.Erprefe,
		  aa.Chequeno,aa.Bankaccno,aa.Drawerbank,aa.Payeebank,aa.Branchdeposited,aa.Depositslip,aa.Createdby,dd.Fullname,aa.DateCreated
		  FROM CustomerAccountTopups aa
		  INNER JOIN SystemStations bb ON aa.StationId=bb.Tenantstationid
		  INNER JOIN Paymentmodes cc ON aa.ModeofPayment=cc.PaymentmodeId
		  INNER JOIN SystemStaffs dd ON aa.Createdby=dd.UserId
		  INNER JOIN Financetransactions ee ON aa.FinanceTransactionId=ee.FinanceTransactionId
		  WHERE A.accountId=aa.accountid
		   FOR JSON PATH 
		) AS CustomerAccounttopups,
		(
		  SELECT aa.EmployeeId,aa.Firstname,aa.Lastname,aa.Emailaddress,aa.Codeharshkey,aa.Employeecode,aa.Changecode,aa.Createdby,aa.Modifiedby,aa.Datecreated,aa.Datemodofied
		  FROM CustomerEmployees aa
		  INNER JOIN AccountEmployee bb ON aa.EmployeeId=bb.EmployeeId
		  WHERE A.accountId=bb.AccountId
		   FOR JSON PATH 
		) AS CustomerAccountemployees,
		(
		  SELECT  aa.EquipmentId,aa.ProductVariationId,cc.Productvariationname,aa.EquipmentModelId,aa.EquipmentRegNo,aa.TankCapacity,aa.Odometer,aa.IsActive,aa.IsDeleted,
		  aa.Createdby,aa.Modifiedby,aa.DateCreated,aa.DateModified
		  FROM CustomerEquipments aa
		  INNER JOIN AccountEquipments bb ON aa.EquipmentId=bb.EquipmentId
		  INNER JOIN SystemProductvariation cc ON aa.ProductVariationId=cc.ProductvariationId
		  INNER JOIN EquipmentModels dd ON aa.EquipmentModelId=dd.EquipmentModelId
		  INNER JOIN EquipmentMakes ee ON dd.EquipmentMakeid=ee.EquipmentMakeId
		  WHERE A.accountId=bb.AccountId
		   FOR JSON PATH 
		) AS CustomerAccountequipments
		FROM CustomerAccount A 
		INNER JOIN CustomerAgreements B ON A.AgreementId = B.AgreementId 
		INNER JOIN Customers  C ON B.CustomerId=C.CustomerId 
		INNER JOIN LoyaltyGroupings D ON A.GroupingId=D.GroupingId 
		INNER JOIN CreditTypes E On A.CredittypeId=E.CredittypeId 
		INNER JOIN ConsumLimitType F ON A.LimitTypeId=F.LimitTypeId 
		INNER JOIN AgreementTypes  G ON B.AgreemettypeId = G.AgreemettypeId
		INNER JOIN SystemAccountCards H ON A.AccountId=H.AccountId
		INNER JOIN Systemcard  I ON H.CardId=I.CardId
		WHERE A.AccountId = @AccountId
		 FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		);

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT @RespStat AS RespStatus, @RespMsg AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountDetailsJson ;
	
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