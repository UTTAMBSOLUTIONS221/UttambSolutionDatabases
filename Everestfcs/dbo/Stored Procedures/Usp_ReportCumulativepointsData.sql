CREATE PROCEDURE [dbo].[Usp_ReportCumulativepointsData] 
@JsonObjectdata VARCHAR(MAX) OUTPUT,
@CustomerPointCumulativeDataJson VARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	---Drop temp tables
IF OBJECT_ID('tempdb..#CardAccounts','u') IS NOT NULL
BEGIN
	DROP TABLE #CardAccounts
END

--DECLARE VARIABLES
DECLARE @VarCount BIGINT,@CardCount BIGINT,@AccountNo BIGINT,@StationName VARCHAR(50),@CustomerName VARCHAR(50),@CardNumber VARCHAR(30),@Contact VARCHAR(50),@CumSalesAmt FLOAT,@CumSalesVol FLOAT,@CumPoints FLOAT

SET @VarCount = 0

--DECLARE TEMP MONTHLY CUMMULATIVE POINTS TABLE
DECLARE @MonCumPoints TABLE(StationName VARCHAR(50),CustomerName VARCHAR(50),CardNumber VARCHAR(30),Contact VARCHAR(50),CumSalesAmt FLOAT, CumSalesVol FLOAT,CumPoints FLOAT)

SELECT * INTO #CardAccounts FROM CustomerAccount
SET @CardCount = (SELECT COUNT(AccountNumber) FROM #CardAccounts)

WHILE  @VarCount < @CardCount 
BEGIN
SET @VarCount = @VarCount + 1
SET @AccountNo = (SELECT TOP 1 AccountNumber FROM #CardAccounts ORDER BY AccountNumber ASC)
--SELECT @StationName
SET @StationName =(SELECT DISTINCT C.Sname FROM SystemStations C WHERE C.StationId=JSON_VALUE(@JsonObjectdata, '$.Station') AND C.TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))
--SELECT @AccountNo
SET @CustomerName = (SELECT DISTINCT RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' '  + ISNULL(LastName, '') + ISNULL(CompanyName, ''))) 
FROM #CardAccounts CA 
INNER JOIN  CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
LEFT JOIN Customers C ON AG.CustomerId = C.CustomerId 
LEFT JOIN SystemTickets T ON T.AccountId=CA.AccountId WHERE CA.AccountNumber = @AccountNo AND T.stationId=JSON_VALUE(@JsonObjectdata, '$.Station'))
--SELECT @CustomerName
SET @CardNumber = (SELECT DISTINCT  MAX(CardSNO) AS SNO FROM #CardAccounts CA 
INNER JOIN SystemAccountCards FCAC ON CA.AccountId=FCAC.AccountId
INNER JOIN Systemcard FC ON FCAC.CardId=FC.CardId
LEFT JOIN SystemTickets T ON T.AccountId=CA.AccountId WHERE CA.AccountNumber = @AccountNo AND T.stationId=JSON_VALUE(@JsonObjectdata, '$.Station')
and TagTypeId=1
GROUP BY CA.AccountId
)
--SELECT @CardNumber
SET @Contact = (SELECT DISTINCT PC.Codename+''+C.Phonenumber AS Phonenumber FROM #CardAccounts CA INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId LEFT JOIN Customers C ON AG.CustomerId = C.CustomerId INNER JOIN SystemPhoneCodes PC ON C.Phoneid=PC.Phoneid LEFT JOIN SystemTickets T ON T.AccountId=CA.AccountId WHERE CA.AccountNumber = @AccountNo AND T.stationId= JSON_VALUE(@JsonObjectdata, '$.Station'))
--SELECT @Contact
SET @CumSalesAmt = CASE WHEN (SELECT DISTINCT SUM(TotalUsed) FROM TicketlinePayments P LEFT JOIN SystemTickets T ON P.TicketId = T.TicketId LEFT JOIN CustomerAccount CA ON T.AccountId = CA.AccountId LEFT JOIN FinanceTransactions FT ON T.FinanceTransactionId = FT.FinanceTransactionId WHERE CA.AccountNumber = @AccountNo AND T.stationId= JSON_VALUE(@JsonObjectdata, '$.Station') AND FT.ActualDate BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) IS NULL THEN '0' ELSE (SELECT DISTINCT SUM(TotalUsed) FROM TicketlinePayments P LEFT JOIN SystemTickets T ON P.TicketId = T.TicketId LEFT JOIN CustomerAccount CA ON T.AccountId = CA.AccountId LEFT JOIN FinanceTransactions FT ON T.FinanceTransactionId = FT.FinanceTransactionId WHERE CA.AccountNumber = @AccountNo AND T.stationId= JSON_VALUE(@JsonObjectdata, '$.Station') AND FT.ActualDate BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) END
--SELECT @CumSalesAmt
SET @CumSalesVol = CASE WHEN (SELECT DISTINCT SUM(Units) FROM TicketLines TL LEFT JOIN SystemTickets T ON TL.TicketId = T.TicketId LEFT JOIN CustomerAccount CA ON T.AccountId = CA.AccountId LEFT JOIN FinanceTransactions FT ON T.FinanceTransactionId = FT.FinanceTransactionId WHERE CA.AccountNumber = @AccountNo AND T.stationId= JSON_VALUE(@JsonObjectdata, '$.Station') AND TL.DateCreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) IS NULL THEN '0' ELSE (SELECT DISTINCT SUM(Units) FROM TicketLines TL LEFT JOIN SystemTickets T ON TL.TicketId = T.TicketId LEFT JOIN CustomerAccount CA ON T.AccountId = CA.AccountId LEFT JOIN FinanceTransactions FT ON T.FinanceTransactionId = FT.FinanceTransactionId WHERE CA.AccountNumber = @AccountNo AND T.stationId= JSON_VALUE(@JsonObjectdata, '$.Station') AND TL.DateCreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) END
--SELECT @CumSalesVol
SET @CumPoints = CASE WHEN (SELECT DISTINCT SUM(R.RewardAmount) FROM Lrresults R LEFT JOIN CustomerAccount CA ON CA.AccountId=R.AccountId  LEFT JOIN LRewards A ON R.LRewardId=A.LRewardId LEFT JOIN LRADataInputs DI ON DI.LRADataInputId=R.LRADataInputId LEFT JOIN LTransactionTypes T ON R.LTransactionTypeId=T.LTransactionTypeId WHERE R.LRewardId=(SELECT A.LRewardId FROM LRewards A WHERE A.RewardName='Points') AND R.LTransactionTypeId=(SELECT T.LTransactionTypeId FROM LTransactionTypes T WHERE T.LTransactionTypeName='Award')AND R.AccountId=(SELECT AccountId FROM CustomerAccount WHERE AccountNumber=@AccountNo)  AND DI.StationId= JSON_VALUE(@JsonObjectdata, '$.Station') AND R.DateCreated  BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) IS NULL THEN '0' ELSE (SELECT DISTINCT SUM(R.RewardAmount) FROM Lrresults R LEFT JOIN CustomerAccount CA ON CA.AccountId=R.AccountId  LEFT JOIN LRewards A ON R.LRewardId=A.LRewardId LEFT JOIN LRADataInputs DI ON DI.LRADataInputId=R.LRADataInputId LEFT JOIN LTransactionTypes T ON R.LTransactionTypeId=T.LTransactionTypeId WHERE R.LRewardId=(SELECT A.LRewardId FROM LRewards A WHERE A.RewardName='Points') AND R.LTransactionTypeId=(SELECT T.LTransactionTypeId FROM LTransactionTypes T WHERE T.LTransactionTypeName='Award')AND R.AccountId=(SELECT AccountId FROM CustomerAccount WHERE AccountNumber=@AccountNo)  AND DI.StationId=JSON_VALUE(@JsonObjectdata, '$.Station') AND R.DateCreated  BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) END
--SELECT @CumPoints

-------Insert to Temp Table--------------------------------------------------------------------------------------------------------------
INSERT INTO @MonCumPoints(StationName,CustomerName,CardNumber,Contact,CumSalesAmt,CumSalesVol,CumPoints)
VALUES(ISNULL(@StationName,''),ISNULL(@CustomerName,''),ISNULL(@CardNumber,''),ISNULL(@Contact,''),ISNULL(@CumSalesAmt,''),ISNULL(@CumSalesVol,''),ISNULL(@CumPoints,''))


-------Delete Account from the #CardAccounts table
DELETE #CardAccounts WHERE AccountNumber = @AccountNo

END

----READ ALL DATA FROM TEMP TABLE--------------------------------------------------------------------------------------------------------------

  SELECT @CustomerPointCumulativeDataJson = (
	     SELECT 
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 THEN 'ALL' ELSE (SELECT RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) FROM Customers C WHERE C.CustomerId=JSON_VALUE(@JsonObjectdata, '$.Customer')) END)AS CustomerName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 THEN 'ALL' ELSE (SELECT  TA.Agreementtypename FROM CustomerAgreements CA INNER JOIN AgreementTypes TA ON CA.AgreemettypeId=TA.AgreemettypeId INNER JOIN CustomerAccount AC ON AC.AgreementId=CA.AgreementId WHERE CA.AgreementId=JSON_VALUE(@JsonObjectdata, '$.Agreement') AND AC.ParentId=0) END)AS AgreementName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END)AS StationName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Paymode') < 1 THEN 'ALL' ELSE (SELECT PM.Paymentmode FROM Paymentmodes PM WHERE PM.PaymentmodeId=JSON_VALUE(@JsonObjectdata, '$.Paymode')) END)AS PaymentModeName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Account') < 1 THEN 'ALL' ELSE (SELECT CS.CardSNO FROM CustomerAccount CA INNER JOIN SystemAccountCards SC ON SC.AccountId=CA.AccountId INNER JOIN Systemcard CS ON CS.CardId=SC.CardId WHERE CA.AccountId=JSON_VALUE(@JsonObjectdata, '$.Account')) END)AS AccountName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT ST.FirstName+' '+ST.LastName AS Fullname FROM SystemStaffs ST WHERE ST.UserId=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END)AS AttendantName,
		    (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Product') < 1 THEN 'ALL' ELSE (SELECT SP.Productvariationname FROM SystemProductvariation SP WHERE SP.ProductvariationId=JSON_VALUE(@JsonObjectdata, '$.Product')) END)AS ProductName,
		   (SELECT * FROM @MonCumPoints M WHERE M.CustomerName IS NOT NULL AND M.CumSalesVol !=0 AND M.CumSalesAmt!=0 AND M.CumPoints!=0  ORDER BY M.CustomerName ASC  FOR JSON PATH
			) AS CustomerPointCumulativeData
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );

END