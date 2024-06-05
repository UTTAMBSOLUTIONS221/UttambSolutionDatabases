
CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerDetailData]
	@CustomerId BIGINT,
	@CustomerDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success',
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
		--validate	

		
		BEGIN TRANSACTION;	

		SET @CurrentPeriodEndDate =(SELECT  DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)));
		SET @PreviousPeriodEndDate =(SELECT DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)));
		SET @CustomerDetails =(
		SELECT 
         a.CustomerId, a.Designation,CASE WHEN Designation='Corporate' THEN a.Companyname ELSE a.Firstname+' '+ a.Lastname END AS Customername,a.CountryId,a.StationId,h.Currencyname AS Currency,
		a.Emailaddress,f.Codename+''+a.Phonenumber AS Phonenumber,ISNULL(a.Dob,GETDATE()) AS Dob,ISNULL(a.Gender,'Not Set') AS Gender, ISNULL(a.IDNumber,'Not Set') AS IDNumber,
		ISNULL(a.CompanyAddress,'Not Set') AS CompanyAddress,ISNULL(a.ReferenceNumber,'Not Set') AS ReferenceNumber,ISNULL(CompanyIncorporationDate,GETDATE()) AS CompanyIncorporationDate,
		ISNULL(a.CompanyRegistrationNo,'Not Set') AS CompanyRegistrationNo,ISNULL(a.CompanyPIN,'Not Set')  AS CompanyPIN,ISNULL(a.CompanyVAT,'Not Set') AS CompanyVAT,ISNULL(a.Contractstartdate,GETDATE()) AS Contractstartdate,
		ISNULL(a.Contractenddate,GETDATE()) AS Contractenddate,b.Sname AS Stationname,c.Countryname,d.Firstname+' '+d.Lastname AS Createdby,e.Firstname+' '+e.Lastname AS Modifiedby,a.Datecreated AS CustomerDatecreated,a.DateModified AS CustomerDateModified,a.NoOfTransactionPerDay,a.AmountPerDay,a.ConsecutiveTransTimeMin,
        (
          SELECT aa.AgreementId,(Select caa.AccountId from CustomerAccount caa WHERE ParentId= 0 AND caa.AgreementId = aa.AgreementId) AS AgreementAccountId,aa.CustomerId,aa.GroupingId,aa.AgreemettypeId,bb.Agreementtypename,aa.PriceListId,cc.PriceListname,aa.DiscountListId,dd.DiscountListname,aa.BillingBasis,aa.Descriptions,aa.AgreementDoc,
           aa.Notes,aa.Hasgroup,aa.HasOverdraft,aa.IsActive,aa.IsDeleted,ii.Firstname+' '+ii.Lastname AS Createdby,jj.Firstname+' '+jj.Lastname AS Modifiedby,aa.Datecreated,aa.Datemodified, ee.Paymentterms,gg.BillingCycleType,gg.BillingCycle,gg.GracePeriod AS RecurrentGracePeriod,gg.NextBillingDate,
		  (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=aa.AgreementId))),0)* -1) AS CustomerBalance,
		  (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=aa.AgreementId  AND CA.ParentId!=0))),0)* -1) AS CustomerAccountBalance,				
		  (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId=(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname=(SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=aa.AgreementId AND CA.ParentId=0 AND CA.IsActive=1 AND CA.IsDeleted=0))),0)* -1) AS CustomerAgreementBalance,
		  (SELECT CAA.CreditLimit FROM CreditAgreements CAA INNER JOIN ConsumLimitType CLT ON CAA.LimitTypeId=CLT.LimitTypeId  WHERE CAA.AgreementId = aa.AgreementId) AS CreditAgreementLimit,
		  (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=aa.AgreementId))),0)* -1) AS CreditAgreementActualDebt,
		  ((SELECT CAA.CreditLimit FROM CreditAgreements CAA INNER JOIN ConsumLimitType CLT ON CAA.LimitTypeId=CLT.LimitTypeId  WHERE CAA.AgreementId = aa.AgreementId)+(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId=aa.AgreementId))),0)* -1)) AS CreditAgreementBalance,
		  (SELECT ISNULL((SELECT SUM(CAST(amount as decimal(18,2))) FROM GLTransactions GL INNER JOIN  FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId WHERE FT.Saledescription in('Sale','SaleReverse') AND ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId = aa.AgreementId  AND FT.ActualDate >= (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM Customers a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.CustomerId=@CustomerId)))), 0))))),0)) AS ConsumptiontoDate,
		  gg.AllowedDebt AS RecurrentAgreementLimit,
		  (gg.AllowedDebt-(SELECT ISNULL((SELECT SUM(CAST(amount as decimal(18,2))) FROM GLTransactions GL INNER JOIN  FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId WHERE FT.Saledescription in('Sale','SaleReverse') AND ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname IN (SELECT CONVERT(VARCHAR(20),CA.AccountNumber) FROM CustomerAccount CA WHERE CA.AgreementId = aa.AgreementId  AND FT.ActualDate >= (SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM Customers a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.CustomerId=@CustomerId)))), 0))))),0))) AS RecurrentAgreementBalance,
		  ( 
	       SELECT  ca.AccountId,ca.AgreementId,ca.AccountNumber,cc.CardId,cc.CardSNO+'-'+cc.CardCode AS CardSNO,ca.GroupingId,ca.ParentId,ca.CredittypeId,ct.Credittypename,ct.Credittypevalue,ca.LimitTypeId,clt.LimitTypename,clt.Limitkey,ca.ConsumptionLimit AS AccountLimit,ca.ConsumptionPeriod,
           (SELECT COUNT(*) FROM AccountEquipments WHERE AccountId=ca.AccountId) AS EquipmentAssigned,(SELECT COUNT(*) FROM AccountEmployee WHERE AccountId=ca.AccountId) AS UsersAssigned,ca.Isadminactive,ca.Iscustomeractive,ca.IsActive,ca.IsDeleted,CBA.Firstname+' '+CBA.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,ca.Datecreated,ca.Datemodified,
		   (SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(20),ca.AccountNumber))),0) * -1) AS PrepaidAccountBalance,
		   CASE WHEN LimitTypename='Litres' THEN
		   (Ca.ConsumptionLimit+(SELECT ISNULL((SELECT SUM(C.Units) FROM GLTransactions A INNER JOIN SystemTickets B ON A.FinanceTransactionId=B.FinanceTransactionId INNER JOIN TicketLines C ON B.TicketId=C.TicketId WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(20),ca.AccountNumber))),0) * -1))
		   ELSE
		   (Ca.ConsumptionLimit+(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(20),ca.AccountNumber))),0) * -1))
		   END  AS CreditAccountBalance,
		   CASE WHEN LimitTypename='Litres' THEN
		   -1*(SELECT ISNULL((SELECT SUM(C.Units) FROM GLTransactions A INNER JOIN SystemTickets B ON A.FinanceTransactionId=B.FinanceTransactionId INNER JOIN TicketLines C ON B.TicketId=C.TicketId WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(20),ca.AccountNumber))),0) * -1)
		   ELSE
		   -1*(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(20),ca.AccountNumber))),0) * -1)
		   END  AS CreditConsumptionBalance,
		   (Ca.ConsumptionLimit-(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(20),ca.AccountNumber))),0) * -1)) AS CreditAccountLimitBalance,
		   (Ca.ConsumptionLimit-(SELECT ISNULL((SELECT SUM(Amount)  FROM GLTransactions WHERE ChartofAccountId IN (SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(20),ca.AccountNumber))),0))) AS RecurrentAccountBalance
			FROM CustomerAccount ca
			LEFT JOIN SystemAccountCards cb ON cb.AccountId=ca.AccountId
			LEFT JOIN Systemcard cc ON cb.CardId=cc.CardId
			LEFT JOIN CreditTypes ct ON ca.CredittypeId=ct.CredittypeId
			LEFT JOIN ConsumLimitType clt ON ca.LimitTypeId=clt.LimitTypeId
			INNER JOIN SystemStaffs CBA ON CA.CreatedBy=CBA.UserId
		   INNER JOIN SystemStaffs MB ON CA.CreatedBy=MB.UserId
			WHERE CA.AgreementId = aa.AgreementId AND CA.ParentId !=0
			FOR JSON PATH
	      ) AS CustomerAccounts
		 FROM CustomerAgreements aa
		 INNER JOIN SystemStaffs ii ON aa.CreatedBy=ii.UserId
		 INNER JOIN SystemStaffs jj ON aa.ModifiedBy=jj.UserId
		 INNER JOIN AgreementTypes bb ON aa.AgreemettypeId=bb.AgreemettypeId
		 INNER JOIN ConsumLimitType hh ON hh.LimitTypeId=bb.LimitTypeId
		 INNER JOIN PriceList cc ON aa.PriceListId=cc.PriceListId
		 INNER JOIN DiscountList dd ON aa.DiscountListId=dd.DiscountListId
		 LEFT JOIN CreditAgreements ee ON ee.AgreementId =aa.AgreementId
		 LEFT JOIN ConsumLimitType ff ON ee.LimitTypeId=ff.LimitTypeId
		 LEFT JOIN PostpaidRecurentAgreements gg ON gg.AgreementId=aa.AgreementId
		 WHERE aa.CustomerId = a.CustomerId
		 FOR JSON PATH
       ) AS CustomerAgreements
    FROM Customers a
	INNER JOIN  SystemStations b ON a.StationId=b.StationId
	INNER JOIN SystemCountry c ON a.CountryId=c.CountryId
	INNER JOIN SystemStaffs d ON a.CreatedBy=d.UserId
	INNER JOIN SystemStaffs e ON a.ModifiedBy=e.UserId
	INNER JOIN SystemPhonecodes f ON a.PhoneId=f.PhoneId
	INNER JOIN Tenantaccounts g ON a.Tenantid=g.Tenantid
	INNER JOIN SystemCountry h ON g.Countryid=h.CountryId
	WHERE a.CustomerId =@CustomerId
    FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
	)

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerDetails as CustomerDetails;

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