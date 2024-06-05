

--EXEC Usp_GetCustomerAccountCardDetailData @SearchParameter='62453645634TEST',@StationId=1,@CustomerAccountDetailsJson=''

CREATE PROCEDURE [dbo].[Usp_GetCustomerAccountCardDetailData]
    @SearchParameter VARCHAR(70),
    @StationId BIGINT,
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
         
			SELECT @CustomeragreementId=AG.AgreementId,@Agreementtypename=ATY.Agreementtypename,@Credittype=CTY.Credittypename,@AccountNumber=CA.AccountNumber  
			FROM CustomerAccount CA 
			INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
			INNER JOIN CreditTypes CTY ON CA.CredittypeId=CTY.CredittypeId
			INNER JOIN AgreementTypes ATY ON AG.AgreemettypeId=ATY.AgreemettypeId
			INNER JOIN SystemAccountCards CAC ON CAC.AccountId = CA.AccountId 
			INNER JOIN Systemcard C ON C.CardId = CAC.CardId WHERE C.CardSNO = @SearchParameter OR C.CardCode= @SearchParameter
			
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

			 SET @CustomerAccountDetailsJson = (SELECT C.CustomerId,RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS CustomerName,PC.Codename  + '' +C.Phonenumber AS Phonenumber,Emailaddress AS CustomerEmail,C.DateCreated,C.IsActive AS CustomerIsActive,COALESCE(C.NoOfTransactionPerDay,0) AS NoOfTransactionPerDay,
			 COALESCE(C.AmountPerDay,0) AS AmountPerDay,COALESCE(C.ConsecutiveTransTimeMin,0) AS ConsecutiveTransTimeMin,AG.AgreementId,AG.BillingBasis,0 AS HasDriverCode,
			 CA.GroupingId,CA.AccountNumber,CT.Credittypename,CT.Credittypevalue,ATY.Agreementtypename,ATY.LimitTypeId,CLT.LimitTypename ,AG.Descriptions,(SELECT TOP 1 CurrencySymbol FROM GeneralSettings A INNER JOIN SystemCurrencies B ON A.CurrencyId = B.CurrencyId) AS Currency,@PostpaidLimitInPeriod AS PostpaidLimitInPeriod,
			 @CustomerPostPaidLimit AS CustomerPostPaidLimit,@AgreementActualBalance AS AgreementActualBalance,
			 @CustomerBalance AS CustomerBalance,@CustomerAccountBalance AS CustomerAccountBalance,
			 (SELECT
			  (
			    SELECT AP.AccountProductId,AP.AccountId,AP.ProductVariationId,AP.LimitValue,AP.LimitPeriod,AP.IsActive,AP.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,AP.DateCreated,AP.DateModified 
				FROM AccountProducts AP
			     INNER JOIN SystemStaffs CB ON AP.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON AP.CreatedBy=MB.UserId
				WHERE AP.AccountId=CA.AccountId
				FOR JSON PATH
			   ) AS AccountProducts,
			   (
			     SELECT ACS.AccountStationId,ACS.AccountId,ACS.StationId,SS.Sname AS StationName,ACS.IsActive,ACS.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,ACS.DateCreated,ACS.DateModified 
				 FROM AccountStations ACS
				 INNER JOIN SystemStations SS ON ACS.StationId=SS.Tenantstationid
				 INNER JOIN SystemStaffs CB ON ACS.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ACS.CreatedBy=MB.UserId
			     WHERE ACS.AccountId=CA.AccountId
				 FOR JSON PATH
			   ) AS AccountStations,
			   (
			     SELECT AWD.AccountWeekDaysId,AWD.AccountId,AWD.WeekDays,AWD.StartTime,AWD.EndTime,AWD.IsActive,AWD.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,AWD.DateCreated,AWD.DateModified 
				 FROM AccountWeekDays AWD
				 INNER JOIN SystemStaffs CB ON AWD.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON AWD.CreatedBy=MB.UserId
			     WHERE AWD.AccountId=CA.AccountId
				 FOR JSON PATH
			   ) AS AccountWeekDay,
			    (
			     SELECT ATF.AccountFrequencyId,ATF.AccountId,ATF.Frequency,ATF.FrequencyPeriod,ATF.IsActive,ATF.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,ATF.DateCreated,ATF.DateModified 
				 FROM AccountTransactionFrequency ATF
				 INNER JOIN SystemStaffs CB ON ATF.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ATF.CreatedBy=MB.UserId
			     WHERE ATF.AccountId=CA.AccountId
				 FOR JSON PATH
			   ) AS AccountTransactionFrequency
			    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
			 ) AS CustomerAccountpolicies,
			 (
			  SELECT CE.EquipmentId,PV.Productvariationname,EMK.EquipmentMake,EM.EquipmentModel,CE.EquipmentRegNo,CE.TankCapacity,CE.Odometer,CE.IsActive,CE.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,CE.DateCreated,CE.DateModified,
			  (SELECT
			   (
			    SELECT EP.EquipmentProductId,EP.EquipmentId,EP.ProductVariationId,EP.LimitValue,EP.LimitPeriod,EP.IsActive,EP.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,EP.DateCreated,EP.DateModified 
				FROM EquipmentProducts EP
			     INNER JOIN SystemStaffs CB ON EP.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EP.CreatedBy=MB.UserId
				WHERE EP.EquipmentId=AE.EquipmentId
				FOR JSON PATH
			   ) AS EquipmentProducts,
			   (
			     SELECT ECS.EquipmentStationId,ECS.EquipmentId,ECS.StationId,SS.Sname AS StationName,ECS.IsActive,ECS.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,ECS.DateCreated,ECS.DateModified 
				 FROM EquipmentStations ECS
				 INNER JOIN SystemStations SS ON ECS.StationId=SS.Tenantstationid
				 INNER JOIN SystemStaffs CB ON ECS.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ECS.CreatedBy=MB.UserId
			     WHERE ECS.EquipmentId=AE.EquipmentId
				 FOR JSON PATH
			   ) AS EquipmentStations,
			   (
			     SELECT EWD.EquipmentWeekDaysId,EWD.EquipmentId,EWD.WeekDays,EWD.StartTime,EWD.EndTime,EWD.IsActive,EWD.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,EWD.DateCreated,EWD.DateModified 
				 FROM EquipmentWeekDays EWD
				 INNER JOIN SystemStaffs CB ON EWD.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EWD.CreatedBy=MB.UserId
			     WHERE EWD.EquipmentId=AE.EquipmentId
				 FOR JSON PATH
			   ) AS EquipmentWeekDays,
			    (
			     SELECT ETF.EquipmentFrequencyId,ETF.EquipmentId,ETF.Frequency,ETF.FrequencyPeriod,ETF.IsActive,ETF.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,ETF.DateCreated,ETF.DateModified 
				 FROM EquipmentTransactionFrequency ETF
				 INNER JOIN SystemStaffs CB ON ETF.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ETF.CreatedBy=MB.UserId
			     WHERE ETF.EquipmentId=AE.EquipmentId
				 FOR JSON PATH
			   ) AS EquipmentTransactionFrequency
			    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
			 ) AS CustomerEquipmentpolicies
				FROM AccountEquipments AE 
                INNER JOIN CustomerEquipments CE ON AE.EquipmentId= CE.EquipmentId
				INNER JOIN SystemProductvariation PV ON CE.ProductVariationId=PV.ProductvariationId
				INNER JOIN EquipmentMakes EMK ON CE.EquipmentMakeId=EMK.EquipmentMakeId
				INNER JOIN EquipmentModels EM ON CE.EquipmentModelId=EM.EquipmentModelId
				INNER JOIN SystemStaffs CB ON CE.CreatedBy=CB.UserId
				INNER JOIN SystemStaffs MB ON CE.CreatedBy=MB.UserId
				WHERE AE.AccountId=CA.AccountId
				FOR JSON PATH
			) AS AccountEquipments,
			(
			  SELECT CE.EmployeeId,CE.Firstname,CE.Lastname,CE.Emailaddress,CE.Employeecode,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,CE.DateCreated,
			  (SELECT
			   (
			    SELECT EP.EmployeeProductId,EP.EmployeeId,EP.ProductVariationId,EP.LimitValue,EP.LimitPeriod,EP.IsActive,EP.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,EP.DateCreated,EP.DateModified 
				FROM EmployeeProducts EP
			     INNER JOIN SystemStaffs CB ON EP.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EP.CreatedBy=MB.UserId
				WHERE EP.EmployeeId=AE.EmployeeId
				FOR JSON PATH
			   ) AS EmployeeProducts,
			   (
			     SELECT ECS.EmployeeStationId,ECS.EmployeeId,ECS.StationId,SS.Sname AS StationName,ECS.IsActive,ECS.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,ECS.DateCreated,ECS.DateModified 
				 FROM EmployeeStations ECS
				 INNER JOIN SystemStations SS ON ECS.StationId=SS.Tenantstationid
				 INNER JOIN SystemStaffs CB ON ECS.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ECS.CreatedBy=MB.UserId
			     WHERE ECS.EmployeeId=AE.EmployeeId
				 FOR JSON PATH
			   ) AS EmployeeStations,
			   (
			     SELECT EWD.EmployeeWeekDaysId,EWD.EmployeeId,EWD.WeekDays,EWD.StartTime,EWD.EndTime,EWD.IsActive,EWD.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,EWD.DateCreated,EWD.DateModified 
				 FROM EmployeeWeekDays EWD
				 INNER JOIN SystemStaffs CB ON EWD.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EWD.CreatedBy=MB.UserId
			     WHERE EWD.EmployeeId=AE.EmployeeId
				 FOR JSON PATH
			   ) AS EmployeeWeekDays,
			    (
			     SELECT ETF.EmployeeFrequencyId,ETF.EmployeeId,ETF.Frequency,ETF.FrequencyPeriod,ETF.IsActive,ETF.IsDeleted,CB.Fullname AS CreatedBy,MB.Fullname AS ModifiedBy,ETF.DateCreated,ETF.DateModified 
				 FROM EmployeeTransactionFrequency ETF
				 INNER JOIN SystemStaffs CB ON ETF.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ETF.CreatedBy=MB.UserId
			     WHERE ETF.EmployeeId=AE.EmployeeId
				 FOR JSON PATH
			   ) AS EmployeeTransactionFrequency
			    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
			 ) AS CustomerEquipmentpolicies
				FROM AccountEmployee AE 
                INNER JOIN CustomerEmployees CE ON AE.EmployeeId= CE.EmployeeId
				INNER JOIN SystemStaffs CB ON CE.CreatedBy=CB.UserId
				INNER JOIN SystemStaffs MB ON CE.CreatedBy=MB.UserId
				WHERE AE.AccountId=CA.AccountId
				FOR JSON PATH
			) AS AccountEmployees

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
			IF NOT EXISTS(SELECT CardId FROM Systemcard WHERE CardSNO=@SearchParameter OR CardCode=@SearchParameter)
			Begin
				 SELECT 1 as RespStatus,'Card does not Exist!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountDetailsJson;
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE CardSNO=@SearchParameter OR CardCode=@SearchParameter AND IsActive=0)
			Begin
				 SELECT 1 as RespStatus,'Card is Marked Inactive!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountDetailsJson;
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE CardSNO=@SearchParameter OR CardCode=@SearchParameter AND IsDeleted=1)
			Begin
				 SELECT 1 as RespStatus,'Card is Marked Deleted!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountDetailsJson;
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE CardSNO=@SearchParameter OR CardCode=@SearchParameter AND IsReplaced=1)
			Begin
				 SELECT 1 as RespStatus,'Card is Marked Replaced!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountDetailsJson;
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE CardSNO=@SearchParameter OR CardCode=@SearchParameter AND IsAssigned=0)
			Begin
				 SELECT 1 as RespStatus,'Card is Marked Unassigned!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountDetailsJson;
				Return
			End
			SELECT @RespStat as RespStatus,@RespMsg AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountDetailsJson;	
    END;
END;