

CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountTopupData]
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
		IF NOT EXISTS(SELECT CloseDayId FROM CloseDays WHERE StartDate = (CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))))) + '00:00:00'))
		BEGIN
		 INSERT INTO CloseDays VALUES((CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))))) + '00:00:00'),(CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT TOP 1 c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))))) + '23:59:59'))
		END
		IF NOT EXISTS(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))), 0) AS datetime)))))
		BEGIN
		 INSERT INTO SystemPeriods 
		 SELECT  DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))), 0) AS datetime)));
		END
		BEGIN TRANSACTION;
		INSERT INTO FinanceTransactions(Tenantid,TransactionCode,FinanceTransactionTypeId,FinanceTransactionSubTypeId,CloseDayId,ParentId,Saledescription,SaleRefence,AutomationRefence,Createdby,ActualDate,DateCreated)
		VALUES(JSON_VALUE(@JsonObjectdata, '$.TenantId'),'TOP'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),(select TOP 1 FinanceTransactionTypeId from FinanceTransactionTypes),(select TOP 1 FinanceTransactionSubTypeId from FinanceTransactionSubTypes),
		(SELECT TOP 1 CloseDayId FROM CloseDays WHERE StartDate>=(CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))))) + '00:00:00') AND EndDate<=(CONVERT(datetime, CONVERT(date, (SELECT dbo.getlocaldate((SELECT TOP 1 c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))))) + '23:59:59') ),0,JSON_VALUE(@JsonObjectdata, '$.TransactionDescription'),JSON_VALUE(@JsonObjectdata, '$.TopupReference'),'TOP'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionAutmationSequence),
		JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
		TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TopupDatecreated') AS datetime2(6)),
		TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))

			SET @FinanceTransactionId = SCOPE_IDENTITY();

			INSERT INTO CustomerAccountTopups(FinanceTransactionId,AccountId,StationId,StaffId,ModeofPayment,Topupreference,Amount,Erprefe,Chequeno,Bankaccno,Drawerbank,Payeebank,Branchdeposited,Depositslip,Createdby,DateCreated)
			VALUES(@FinanceTransactionId,JSON_VALUE(@JsonObjectdata, '$.AccountId'),JSON_VALUE(@JsonObjectdata, '$.StationId'),JSON_VALUE(@JsonObjectdata, '$.StaffId'),JSON_VALUE(@JsonObjectdata, '$.PaymentModeId'),JSON_VALUE(@JsonObjectdata, '$.TopupReference'),JSON_VALUE(@JsonObjectdata, '$.TopupAmount'),JSON_VALUE(@JsonObjectdata, '$.TopupErpReference'),JSON_VALUE(@JsonObjectdata, '$.AccounTopupChequenumber'),JSON_VALUE(@JsonObjectdata, '$.TopupBankAccount'),JSON_VALUE(@JsonObjectdata, '$.TopupDrawerBank'),JSON_VALUE(@JsonObjectdata, '$.TopupPayeeBank'),JSON_VALUE(@JsonObjectdata, '$.TopupBranchDeposited'),JSON_VALUE(@JsonObjectdata, '$.TopupDepostiSlip'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

			INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
			VALUES(@FinanceTransactionId,
			(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId'))),
			(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))), 0) AS datetime))))),(SELECT TOP 1 c.Currencyname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')),-1 * CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TopupAmount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.TopupDatecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

			INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,PeriodId,Currency,Amount,GlActualDate,DateCreated)
			VALUES(@FinanceTransactionId,
			(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname='Accounts Receivable'),
			(SELECT PeriodId FROM SystemPeriods WHERE Lastdateinperiod =(SELECT DATEADD(SECOND, -1, DATEADD(DAY, 1, CAST(EOMONTH((SELECT dbo.getlocaldate((SELECT c.Utcname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')))), 0) AS datetime))))),(SELECT TOP 1 c.Currencyname FROM SystemStaffs a  INNER JOIN Tenantaccounts b ON a.Tenantid=b.Tenantid INNER JOIN SystemCountry c ON b.Countryid=c.CountryId WHERE a.Userid=JSON_VALUE(@JsonObjectdata, '$.CreatedbyId')),-1 * CONVERT(decimal(10,4),(JSON_VALUE(@JsonObjectdata, '$.TopupAmount'))),CAST(JSON_VALUE(@JsonObjectdata, '$.TopupDatecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))


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
