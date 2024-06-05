CREATE PROCEDURE [dbo].[Usp_ReportAwardStatementData] 
	@JsonObjectdata VARCHAR(MAX) OUTPUT,
	@PointAwardStatementDataDetailsJson VARCHAR(MAX) OUTPUT
as
begin
SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END  
IF OBJECT_ID('tempdb..#temptable','u') IS NOT NULL
	BEGIN
		DROP TABLE #temptable
	END

	Declare @bal float = 0;
	SELECT LRR.DateCreated AS Date,LT.LTransactionTypeName AS Description,
	RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS Customer,C.IDNumber AS Customeridnumber,
	SC.CardSNO AS Mask,CV.EquipmentRegNo  AS Equipment,0 AS Debit,RewardAmount AS Credit,CA.AccountNumber,RewardAmount As Balance 
	into #temptable 
	FROM LRResults AS LRR
	INNER JOIN LRADataInputs AS DI ON DI.LRADataInputId = LRR.LRADataInputId
	INNER JOIN SystemTickets T ON T.FinanceTransactionId=DI.FinanceTransactionId
	INNER JOIN  CustomerVehicleUsages FMU ON FMU.TicketId=T.TicketId
	INNER JOIN CustomerEquipments CV ON CV.EquipmentId=FMU.EquipmentId
	INNER JOIN LTransactionTypes AS LT ON LT.LTransactionTypeId = LRR.LTransactionTypeId
	INNER JOIN CustomerAccount AS CA ON CA.AccountId = LRR.AccountId
	INNER JOIN SystemAccountCards SAC ON SAC.AccountId=CA.AccountId
	INNER JOIn Systemcard SC ON  SAC.CardId=SC.CardId
	INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
	INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
	WHERE  LRR.LTransactionTypeId = (SELECT LTransactionTypeId FROM LTransactionTypes Where LTransactionTypeName = 'Award')
	AND LRR.LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
	AND LRR.AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
	AND LRR.DateCreated BETWEEN  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND (dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))) 


insert into #temptable 

SELECT LRR.DateCreated AS Date,LT.LTransactionTypeName AS Description,
RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' '  + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS Customer,C.IDNumber AS Customeridnumber,
(SELECT TOP 1 CardSNO FROM Systemcard Where CardId in (SELECT CardId FROM SystemAccountCards Where AccountId = (SELECT AccountId FROM CustomerAccount Where AccountNumber = CA.AccountNumber ))AND TagTypeId in (SELECT TOP 1 TagtypeId FROM Systemcardtype Where TagTypename in ('Card','Tag')) ) AS Mask
,CV.EquipmentRegNo  AS Equipment,
(CASE WHEN RewardAmount<0 THEN  LRR.RewardAmount ELSE 0 END) AS Debit,
(CASE WHEN RewardAmount>0 THEN  LRR.RewardAmount ELSE 0 END) AS Credit,
CA.AccountNumber,RewardAmount As Balance FROM LRResults AS LRR
INNER JOIN LRADataInputs AS DI ON DI.LRADataInputId = LRR.LRADataInputId
INNER JOIN SystemTickets T ON T.FinanceTransactionId=DI.FinanceTransactionId
INNER JOIN  CustomerVehicleUsages FMU ON FMU.TicketId=T.TicketId
INNER JOIN CustomerEquipments CV ON CV.EquipmentId=FMU.EquipmentId
INNER JOIN LTransactionTypes AS LT ON LT.LTransactionTypeId = LRR.LTransactionTypeId
INNER JOIN CustomerAccount AS CA ON CA.AccountId = LRR.AccountId
INNER JOIN SystemAccountCards SAC ON SAC.AccountId=CA.AccountId
INNER JOIn Systemcard SC ON  SAC.CardId=SC.CardId
INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
WHERE LRR.LTransactionTypeId = (SELECT LTransactionTypeId FROM LTransactionTypes Where LTransactionTypeName = 'Conversion')
AND LRR.LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
AND LRR.AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
AND LRR.DateCreated BETWEEN  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND (dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))) 


insert into #temptable 

SELECT LRR.DateCreated AS Date,LT.LTransactionTypeName AS Description,
RTRIM(LTRIM(ISNULL(C.FirstName, '')  + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS Customer,C.IDNumber AS Customeridnumber,
(SELECT TOP 1 CardSNO FROM Systemcard Where CardId in (SELECT CardId FROM SystemAccountCards Where AccountId = (SELECT AccountId FROM CustomerAccount Where AccountNumber = CA.AccountNumber ))AND TagTypeId in (SELECT TOP 1 TagtypeId FROM Systemcardtype Where TagTypename in ('Card','Tag')) ) AS Mask
,CV.EquipmentRegNo  AS Equipment,
(CASE WHEN RewardAmount<0 THEN  LRR.RewardAmount ELSE 0 END) AS Debit,
(CASE WHEN RewardAmount>0 THEN  LRR.RewardAmount ELSE 0 END) AS Credit,
CA.AccountNumber,RewardAmount As Balance FROM LRResults AS LRR
INNER JOIN LRADataInputs AS DI ON DI.LRADataInputId = LRR.LRADataInputId
INNER JOIN SystemTickets T ON T.FinanceTransactionId=DI.FinanceTransactionId
INNER JOIN  CustomerVehicleUsages FMU ON FMU.TicketId=T.TicketId
INNER JOIN CustomerEquipments CV ON CV.EquipmentId=FMU.EquipmentId
INNER JOIN LTransactionTypes AS LT ON LT.LTransactionTypeId = LRR.LTransactionTypeId
INNER JOIN CustomerAccount AS CA ON CA.AccountId = LRR.AccountId
INNER JOIN SystemAccountCards SAC ON SAC.AccountId=CA.AccountId
INNER JOIn Systemcard SC ON  SAC.CardId=SC.CardId
INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
WHERE LRR.LTransactionTypeId = (SELECT LTransactionTypeId FROM LTransactionTypes Where LTransactionTypeName = 'Adjustment')
AND LRR.LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
AND LRR.AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
AND LRR.DateCreated BETWEEN  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND (dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))) 


insert into #temptable 

SELECT LRR.DateCreated AS Date,LT.LTransactionTypeName AS Description,
RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS Customer,C.IDNumber AS Customeridnumber,
(SELECT TOP 1 CardSNO FROM Systemcard Where CardId in (SELECT CardId FROM SystemAccountCards Where AccountId = (SELECT AccountId FROM CustomerAccount Where AccountNumber = CA.AccountNumber ))AND TagTypeId in (SELECT TOP 1 TagtypeId FROM Systemcardtype Where TagTypename in ('Card','Tag')) ) AS Mask
,CV.EquipmentRegNo  AS Equipment,
(CASE WHEN RewardAmount<0 THEN  LRR.RewardAmount ELSE 0 END) AS Debit,
(CASE WHEN RewardAmount>0 THEN  LRR.RewardAmount ELSE 0 END) AS Credit,

CA.AccountNumber,RewardAmount As Balance FROM LRResults AS LRR
INNER JOIN LRADataInputs AS DI ON DI.LRADataInputId = LRR.LRADataInputId
INNER JOIN SystemTickets T ON T.FinanceTransactionId=DI.FinanceTransactionId
INNER JOIN  CustomerVehicleUsages FMU ON FMU.TicketId=T.TicketId
INNER JOIN CustomerEquipments CV ON CV.EquipmentId=FMU.EquipmentId
INNER JOIN LTransactionTypes AS LT ON LT.LTransactionTypeId = LRR.LTransactionTypeId
INNER JOIN CustomerAccount AS CA ON CA.AccountId = LRR.AccountId
INNER JOIN SystemAccountCards SAC ON SAC.AccountId=CA.AccountId
INNER JOIn Systemcard SC ON  SAC.CardId=SC.CardId
INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
WHERE LRR.LTransactionTypeId = (SELECT LTransactionTypeId FROM LTransactionTypes Where LTransactionTypeName = 'Reverse')
AND LRR.LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
AND LRR.AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
AND LRR.DateCreated BETWEEN  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND (dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))) 



declare @openingBalance float = 0;

if(JSON_VALUE(@JsonObjectdata, '$.Account') < 1)
BEGIN 
    set @openingBalance = (SELECT SUM(RewardAmount) AS Rewards FROM LRResults Where LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
                           AND AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
                           AND DateCreated <=  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)));
END
ELSE If(JSON_VALUE(@JsonObjectdata, '$.Account') > 1)
BEGIN
    set @openingBalance  = (SELECT SUM(RewardAmount) AS Rewards FROM LRResults Where LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
                           AND AccountId = JSON_VALUE(@JsonObjectdata, '$.Account')
                           AND DateCreated <=  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)));

END


INSERT INTO #temptable
SELECT  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS Date,'Opening Balance' AS Description,'' AS Customer,'' AS Customeridnumber,'' AS Mask,'' AS Equipment,0  AS Debit,IsNull(@openingBalance,0) AS Credit,0 AS AccountNumber,IsNull(@openingBalance,0) AS Balance

SELECT @PointAwardStatementDataDetailsJson = (
	     SELECT 
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 THEN 'ALL' ELSE (SELECT RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) FROM Customers C WHERE C.CustomerId=JSON_VALUE(@JsonObjectdata, '$.Customer')) END)AS CustomerName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 THEN 'ALL' ELSE (SELECT  TA.Agreementtypename FROM CustomerAgreements CA INNER JOIN AgreementTypes TA ON CA.AgreemettypeId=TA.AgreemettypeId INNER JOIN CustomerAccount AC ON AC.AgreementId=CA.AgreementId WHERE CA.AgreementId=JSON_VALUE(@JsonObjectdata, '$.Agreement') AND AC.ParentId=0) END)AS AgreementName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Account') < 1 THEN 'ALL' ELSE (SELECT CS.CardSNO FROM CustomerAccount CA INNER JOIN SystemAccountCards SC ON SC.AccountId=CA.AccountId INNER JOIN Systemcard CS ON CS.CardId=SC.CardId WHERE CA.AccountId=JSON_VALUE(@JsonObjectdata, '$.Account')) END)AS AccountName,
            (select Date,Description,Customer,Customeridnumber,Mask,IsNull(Equipment,'N/A') AS Equipment,'' AS StationName,'' AS StaffName,Debit,Credit,AccountNumber,+ SUM(Balance) OVER (ORDER BY Date) AS Balance from #temptable FOR JSON PATH) AS PointsStatementData
			  FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER);
drop table #temptable

end


SET ANSI_NULLS ON

