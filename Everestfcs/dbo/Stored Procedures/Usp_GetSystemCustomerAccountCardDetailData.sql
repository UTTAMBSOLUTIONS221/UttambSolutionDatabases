CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAccountCardDetailData]
    @JsonObjectdata VARCHAR(MAX),
    @CustomerAccountDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN
    DECLARE 
        @RespStat INT = 0,
        @RespMsg VARCHAR(150) = 'Success',
		@CustomerAccountDetailsJsonData  VARCHAR(MAX),
		@AccountNumber BIGINT,
		@AgreementtypeId BIGINT,
		@CustomeragreementId BIGINT,
		@Agreementtypename VARCHAR(100),
		@ConsumptionLimittypename VARCHAR(50),
		@Credittype VARCHAR(50),
		@ConsumptionPeriod VARCHAR(50),
		@BillingBasis VARCHAR(50),
		@Discounttype VARCHAR(50),
		@ProductPrice DECIMAL(18,2)= 0,
		@Discountvalue DECIMAL(18,2)= 0,
		@PrepaidBfwdInPeriod DECIMAL(18,2)= 0,
		@AccountTxnSumAmount DECIMAL(18,2)= 0,
		@PostpaidLimitInPeriod DECIMAL(18,2)= 0,
		@CustomerBalance DECIMAL(18,2)= 0,
		@CustomerPostPaidLimit DECIMAL(18,2)= 0,
		@CustomerAccountBalance DECIMAL(18,2)= 0,
		@AgreementActualBalance DECIMAL(18,2)= 0,
		@AgreementBalance DECIMAL(18,2)= 0,
	    @RedeemConvertionvalue DECIMAL(18,2)= 0,
		@AgreementStartDate DATETIME,
		@AgreementEndDate DATETIME,
        @CurrentPeriodEndDate DATETIME,
        @PreviousPeriodEndDate DATETIME;
		IF OBJECT_ID('tempdb..#CustomerStationProducts', 'U') IS NOT NULL
        DROP TABLE #CustomerStationProducts
    BEGIN
           SET @RedeemConvertionvalue=(SELECT CASE WHEN AutoRedeem=0 THEN ConversionValue ELSE 0 END FROM LoyaltySettings  WHERE FromRewardId=(SELECT LRewardId FROM LRewards WHERE RewardName='Points') AND ToRewardId =(SELECT LRewardId FROM LRewards WHERE RewardName='Discount Voucher') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))
			SELECT @CustomeragreementId=AG.AgreementId,@Agreementtypename=ATY.Agreementtypename,@Credittype=CTY.Credittypename,@AccountNumber=CA.AccountNumber  
			FROM CustomerAccount CA 
			INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
			INNER JOIN CreditTypes CTY ON CA.CredittypeId=CTY.CredittypeId
			INNER JOIN AgreementTypes ATY ON AG.AgreemettypeId=ATY.AgreemettypeId
			INNER JOIN SystemAccountCards CAC ON CAC.AccountId = CA.AccountId 
			INNER JOIN Systemcard C ON C.CardId = CAC.CardId WHERE C.CardSNO= LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo')) OR C.CardCode = LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo'))

			SELECT PV.ProductvariationId,PV.Productvariationname,PC.Categoryname,PLP.ProductPrice,0 AS Discountvalue,'Not Applicable' AS Discounttype,AG.DiscountListId
			INTO #CustomerStationProducts FROM SystemProductvariation PV 
			INNER JOIN SystemProduct P ON P.ProductId = PV.ProductId 
			INNER JOIN Productcategory PC ON PC.CategoryId = P.CategoryId 
			INNER JOIN PriceListPrices PLP ON PLP.ProductVariationId = PV.ProductvariationId 
			INNER JOIN SystemStations STN ON STN.StationId = PLP.StationId 
			INNER JOIN PriceList  PL ON PL.PriceListId = PLP.PriceListId 
			INNER JOIN CustomerAgreements AG ON PLP.PriceListId = AG.PriceListId 
			INNER JOIN CustomerAccount CA ON CA.AgreementId = AG.AgreementId 
			WHERE CA.AccountNumber = @AccountNumber AND (PLP.StationId = JSON_VALUE(@JsonObjectdata, '$.StationId'))

			UPDATE PV SET PV.Discountvalue=LDP.DiscountValue,PV.Discounttype=LDP.Discounttype
			FROM #CustomerStationProducts PV INNER JOIN LnkDiscountProducts  LDP on PV.ProductvariationId = LDP.ProductVariationId
			AND LDP.DiscountlistId=PV.DiscountListId

			SELECT @ProductPrice=ProductPrice,@Discountvalue=Discountvalue,@Discounttype=Discounttype FROM #CustomerStationProducts
			IF(@Discounttype='Percentage')
			BEGIN
			 UPDATE #CustomerStationProducts SET Discountvalue = ((@Discountvalue * @ProductPrice) / 100);
			END

			 IF(@Credittype='Prepaid')
			 BEGIN
				 SET @CurrentPeriodEndDate =DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId))), 0) AS datetime)));
				 SET @PreviousPeriodEndDate=DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId))), -1) AS datetime))); 
				 SET @PrepaidBfwdInPeriod = (SELECT ISNULL((SELECT Bbfwd FROM ChartofAccountPeriodBalances WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=CONVERT(VARCHAR(20),@AccountNumber)) AND PeriodId=(SELECT PeriodId FROM SystemPeriods WHERE LastDateInPeriod=@PreviousPeriodEndDate)),0) AS Bbfwd)
				 SET @AccountTxnSumAmount = (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=CONVERT(VARCHAR(20),@AccountNumber)) AND PeriodId IN(SELECT PeriodId from SystemPeriods WHERE LastDateInPeriod BETWEEN @PreviousPeriodEndDate AND @CurrentPeriodEndDate)),0) AS Total)
				 --SET @CustomerAccountBalance = ((@PrepaidBfwdInPeriod) + (@AccountTxnSumAmount)) * -1;
				 SET @CustomerBalance=(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=@CustomeragreementId))),0)* -1 AS Total)
				 SET @CustomerAccountBalance =(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=CONVERT(VARCHAR(20),@AccountNumber))),0)* -1 AS Total)
			 END
			 ELSE
			 BEGIN
			   SELECT @PostpaidLimitInPeriod=ConsumptionLimit,@ConsumptionPeriod=ConsumptionPeriod,@ConsumptionLimittypename=CLT.LimitTypename FROM CustomerAccount CA INNER JOIN ConsumLimitType CLT ON CA.LimitTypeId=CLT.LimitTypeId WHERE AccountNumber = @AccountNumber
			   SET @AgreementEndDate=(SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId)));
			   SET @AgreementStartDate= (CASE @ConsumptionPeriod
									WHEN 'Daily' THEN CAST((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId))) AS DATETIME2(0)) -- For daily start
									WHEN 'Weekly' THEN CAST(DATEADD(DAY, 1 - DATEPART(WEEKDAY, (SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId)))), CAST((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId))) AS DATE)) AS DATETIME2(0)) -- For weekly start
									ELSE CAST(DATEFROMPARTS(YEAR((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId)))), MONTH((SELECT dbo.getlocaldate((SELECT TOP 1 e.Utcname FROM CustomerAccount a INNER JOIN CustomerAgreements b ON a.AgreementId=b.AgreementId INNER JOIN Customers c ON b.CustomerId=c.CustomerId INNER JOIN Tenantaccounts d ON c.Tenantid=d.Tenantid INNER JOIN SystemCountry e ON d.Countryid=e.CountryId WHERE a.AgreementId=@CustomeragreementId)))), 1) AS DATETIME2(0)) -- For monthly start
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

			 SET @CustomerAccountDetailsJson = (SELECT @RespStat as RespStatus,@RespMsg AS RespMessage,(SELECT C.CustomerId,RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS CustomerName,PC.Codename  + '' +C.Phonenumber AS Phonenumber,C.Emailaddress AS CustomerEmail,C.DateCreated,C.IsActive AS CustomerIsActive,COALESCE(C.NoOfTransactionPerDay,0) AS NoOfTransactionPerDay,
			 COALESCE(C.AmountPerDay,0) AS AmountPerDay,COALESCE(C.ConsecutiveTransTimeMin,0) AS ConsecutiveTransTimeMin,AG.AgreementId,AG.BillingBasis,SC.CardId,SC.CardUID AS CardUID,SC.CardCode,SC.CardSNO+'-'+SC.CardCode AS CardSNO,0 AS HasDriverCode,CA.AccountId,
			 CA.GroupingId,CA.AccountNumber,CT.Credittypename,CT.Credittypevalue,ATY.Agreementtypename,ATY.LimitTypeId,CLT.LimitTypename ,AG.Descriptions,h.Currencyname AS Currency,@PostpaidLimitInPeriod AS PostpaidLimitInPeriod,
			 @CustomerPostPaidLimit AS CustomerPostPaidLimit,@AgreementActualBalance AS AgreementActualBalance,
			 @CustomerBalance AS CustomerBalance,@CustomerAccountBalance AS CustomerAccountBalance,
			 (
				Select r.Paymentmode as Text, r.PaymentmodeId as Value,r.PaymentmodetypeId AS GroupId,p.Paymentmodetype AS Groupname From Paymentmodes r inner join Paymentmodetypes p on r.PaymentmodetypeId=p.PaymentmodetypeId WHERE r.Paymentmode in('Card','Cash','Ivoucher') order by r.Paymentmode asc
				 FOR JSON PATH
			 ) AS PaymentModes,
			 (
			    SELECT AP.AccountProductId,AP.AccountId,AP.ProductVariationId,AP.LimitValue,AP.LimitPeriod,AP.IsActive,AP.IsDeleted,CB.Firstname +' '+CB.Lastname AS CreatedBy,MB.Firstname +' '+MB.Lastname AS ModifiedBy,AP.DateCreated,AP.DateModified 
				FROM AccountProducts AP
			     INNER JOIN SystemStaffs CB ON AP.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON AP.CreatedBy=MB.UserId
				WHERE AP.AccountId=CA.AccountId
				FOR JSON PATH
			   ) AS AccountProducts,
			   (
			     SELECT ACS.AccountStationId,ACS.AccountId,ACS.StationId,SS.Sname AS StationName,ACS.IsActive,ACS.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,ACS.DateCreated,ACS.DateModified 
				 FROM AccountStations ACS
				 INNER JOIN SystemStations SS ON ACS.StationId=SS.StationId
				 INNER JOIN SystemStaffs CB ON ACS.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ACS.CreatedBy=MB.UserId
			     WHERE ACS.AccountId=CA.AccountId
				 FOR JSON PATH
			   ) AS AccountStations,
			   (
			     SELECT AWD.AccountWeekDaysId,AWD.AccountId,AWD.WeekDays,AWD.StartTime,AWD.EndTime,AWD.IsActive,AWD.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,AWD.DateCreated,AWD.DateModified 
				 FROM AccountWeekDays AWD
				 INNER JOIN SystemStaffs CB ON AWD.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON AWD.CreatedBy=MB.UserId
			     WHERE AWD.AccountId=CA.AccountId
				 FOR JSON PATH
			   ) AS AccountWeekDay,
			    (
			     SELECT ATF.AccountFrequencyId,ATF.AccountId,ATF.Frequency,ATF.FrequencyPeriod,ATF.IsActive,ATF.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,ATF.DateCreated,ATF.DateModified 
				 FROM AccountTransactionFrequency ATF
				 INNER JOIN SystemStaffs CB ON ATF.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ATF.CreatedBy=MB.UserId
			     WHERE ATF.AccountId=CA.AccountId
				 FOR JSON PATH
			   ) AS AccountTransactionFrequency,
			   (
			  SELECT CE.EquipmentId,PV.Productvariationname,EMK.EquipmentMake,EM.EquipmentModel,CE.EquipmentRegNo,CE.TankCapacity,CE.Odometer,CE.IsActive,CE.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,CE.DateCreated,CE.DateModified,
			  (
			    SELECT EP.EquipmentProductId,EP.EquipmentId,EP.ProductVariationId,EP.LimitValue,EP.LimitPeriod,EP.IsActive,EP.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,EP.DateCreated,EP.DateModified 
				FROM EquipmentProducts EP
			     INNER JOIN SystemStaffs CB ON EP.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EP.CreatedBy=MB.UserId
				WHERE EP.EquipmentId=AE.EquipmentId
				FOR JSON PATH
			   ) AS EquipmentProducts,
			   (
			     SELECT ECS.EquipmentStationId,ECS.EquipmentId,ECS.StationId,SS.Sname AS StationName,ECS.IsActive,ECS.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,ECS.DateCreated,ECS.DateModified 
				 FROM EquipmentStations ECS
				 INNER JOIN SystemStations SS ON ECS.StationId=SS.StationId
				 INNER JOIN SystemStaffs CB ON ECS.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ECS.CreatedBy=MB.UserId
			     WHERE ECS.EquipmentId=AE.EquipmentId
				 FOR JSON PATH
			   ) AS EquipmentStations,
			   (
			     SELECT EWD.EquipmentWeekDaysId,EWD.EquipmentId,EWD.WeekDays,EWD.StartTime,EWD.EndTime,EWD.IsActive,EWD.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,EWD.DateCreated,EWD.DateModified 
				 FROM EquipmentWeekDays EWD
				 INNER JOIN SystemStaffs CB ON EWD.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EWD.CreatedBy=MB.UserId
			     WHERE EWD.EquipmentId=AE.EquipmentId
				 FOR JSON PATH
			   ) AS EquipmentWeekDays,
			    (
			     SELECT ETF.EquipmentFrequencyId,ETF.EquipmentId,ETF.Frequency,ETF.FrequencyPeriod,ETF.IsActive,ETF.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,ETF.DateCreated,ETF.DateModified 
				 FROM EquipmentTransactionFrequency ETF
				 INNER JOIN SystemStaffs CB ON ETF.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ETF.CreatedBy=MB.UserId
			     WHERE ETF.EquipmentId=AE.EquipmentId
				 FOR JSON PATH
			   ) AS EquipmentTransactionFrequency
				FROM AccountEquipments AE 
                INNER JOIN CustomerEquipments CE ON AE.EquipmentId= CE.EquipmentId
				INNER JOIN SystemProductvariation PV ON CE.ProductVariationId=PV.ProductvariationId
				INNER JOIN EquipmentMakes EMK ON CE.EquipmentMakeId=EMK.EquipmentMakeId
				INNER JOIN EquipmentModels EM ON CE.EquipmentModelId=EM.EquipmentModelId
				INNER JOIN SystemStaffs CB ON CE.CreatedBy=CB.UserId
				INNER JOIN SystemStaffs MB ON CE.CreatedBy=MB.UserId
				WHERE AE.AccountId=CA.AccountId
				FOR JSON PATH
			) AS CustomerAccountEquipment,
			(
			  SELECT CE.EmployeeId,CE.Firstname,CE.Lastname,CE.Emailaddress,CE.Employeecode,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,CE.DateCreated,
			  (
			    SELECT EP.EmployeeProductId,EP.EmployeeId,EP.ProductVariationId,EP.LimitValue,EP.LimitPeriod,EP.IsActive,EP.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,EP.DateCreated,EP.DateModified 
				FROM EmployeeProducts EP
			     INNER JOIN SystemStaffs CB ON EP.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EP.CreatedBy=MB.UserId
				WHERE EP.EmployeeId=AE.EmployeeId
				FOR JSON PATH
			   ) AS EmployeeProducts,
			   (
			     SELECT ECS.EmployeeStationId,ECS.EmployeeId,ECS.StationId,SS.Sname AS StationName,ECS.IsActive,ECS.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,ECS.DateCreated,ECS.DateModified 
				 FROM EmployeeStations ECS
				 INNER JOIN SystemStations SS ON ECS.StationId=SS.StationId
				 INNER JOIN SystemStaffs CB ON ECS.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ECS.CreatedBy=MB.UserId
			     WHERE ECS.EmployeeId=AE.EmployeeId
				 FOR JSON PATH
			   ) AS EmployeeStations,
			   (
			     SELECT EWD.EmployeeWeekDaysId,EWD.EmployeeId,EWD.WeekDays,EWD.StartTime,EWD.EndTime,EWD.IsActive,EWD.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,EWD.DateCreated,EWD.DateModified 
				 FROM EmployeeWeekDays EWD
				 INNER JOIN SystemStaffs CB ON EWD.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON EWD.CreatedBy=MB.UserId
			     WHERE EWD.EmployeeId=AE.EmployeeId
				 FOR JSON PATH
			   ) AS EmployeeWeekDays,
			    (
			     SELECT ETF.EmployeeFrequencyId,ETF.EmployeeId,ETF.Frequency,ETF.FrequencyPeriod,ETF.IsActive,ETF.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,ETF.DateCreated,ETF.DateModified 
				 FROM EmployeeTransactionFrequency ETF
				 INNER JOIN SystemStaffs CB ON ETF.CreatedBy=CB.UserId
				 INNER JOIN SystemStaffs MB ON ETF.CreatedBy=MB.UserId
			     WHERE ETF.EmployeeId=AE.EmployeeId
				 FOR JSON PATH
			   ) AS EmployeeTransactionFrequency
				FROM AccountEmployee AE 
                INNER JOIN CustomerEmployees CE ON AE.EmployeeId= CE.EmployeeId
				INNER JOIN SystemStaffs CB ON CE.CreatedBy=CB.UserId
				INNER JOIN SystemStaffs MB ON CE.CreatedBy=MB.UserId
				WHERE AE.AccountId=CA.AccountId
				FOR JSON PATH
			) AS AccountEmployees,
			 (
			   SELECT ProductvariationId,Productvariationname,Categoryname,ProductPrice,Discountvalue,Discounttype FROM #CustomerStationProducts
			   FOR JSON PATH
			 ) AS CustomerAccountProducts,
			 (
				 SELECT LR.LRewardId,LW.RewardName,SUM(LR.RewardAmount) AS RewardValue,(SUM(LR.RewardAmount)/@RedeemConvertionvalue) AS RewardRedeemValue
				 FROM LRResults LR 
				 INNER JOIN LRewards LW ON LR.LRewardId=LW.LRewardId 
				 WHERE LR.AccountId=CA.AccountId
				 GROUP BY LW.RewardName,LR.LRewardId
				FOR JSON PATH
			 ) AS CustomerAccountRewards
			 FROM CustomerAccount CA
			 INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
			 INNER JOIN SystemAccountCards SAC ON SAC.AccountId= CA.AccountId
			 INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
			 INNER JOIN Customers C ON C.CustomerId=AG.CustomerId 
			 INNER JOIN SystemPhoneCodes PC ON C.Phoneid=PC.Phoneid
			 INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
			 INNER JOIN AgreementTypes ATY ON AG.AgreemettypeId=ATY.AgreemettypeId
			 INNER JOIN ConsumLimitType CLT ON ATY.LimitTypeId=CLT.LimitTypeId
			 INNER JOIN Tenantaccounts g ON C.Tenantid=g.Tenantid
	         INNER JOIN SystemCountry h ON g.Countryid=h.CountryId
			 WHERE CA.AccountNumber = @AccountNumber AND CA.ParentId!=0
			  FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
			) AS CustomerAccountCardDetail
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
			)
			IF NOT EXISTS(SELECT CardId FROM Systemcard WHERE CardSNO= UPPER(JSON_VALUE(@JsonObjectdata, '$.CardNo')) OR CardCode = UPPER(JSON_VALUE(@JsonObjectdata, '$.CardNo')))
			Begin
				SELECT(SELECT 1 as RespStatus,'Card does not Exist!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountCardDetail FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER) AS CustomerAccountDetailsJson;	
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE IsActive=0 AND CardSNO= UPPER(JSON_VALUE(@JsonObjectdata, '$.CardNo')) OR CardCode = UPPER(JSON_VALUE(@JsonObjectdata, '$.CardNo')))
			Begin
				 SELECT(SELECT 1 as RespStatus,'Card is Marked Inactive!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountCardDetail FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER) AS CustomerAccountDetailsJson;	
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE  IsDeleted=1 AND CardSNO= LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo')) OR CardCode = LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo')))
			Begin
				 SELECT(SELECT 1 as RespStatus,'Card is Marked Deleted!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountCardDetail FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER) AS CustomerAccountDetailsJson;	
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE IsReplaced=1 AND  CardSNO= LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo')) OR CardCode = LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo')))
			Begin
				 SELECT(SELECT 1 as RespStatus,'Card is Marked Replaced!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountCardDetail FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER) AS CustomerAccountDetailsJson;	
				Return
			End
			IF EXISTS(SELECT CardId FROM Systemcard WHERE IsAssigned=0 AND CardSNO= LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo')) OR CardCode = LOWER(JSON_VALUE(@JsonObjectdata, '$.CardNo')))
			Begin
				 SELECT (SELECT 1 as RespStatus,'Card is Marked Unassigned!' AS RespMessage, @CustomerAccountDetailsJson AS CustomerAccountCardDetail FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER) AS CustomerAccountDetailsJson;	
				Return
			End
    END;
END;