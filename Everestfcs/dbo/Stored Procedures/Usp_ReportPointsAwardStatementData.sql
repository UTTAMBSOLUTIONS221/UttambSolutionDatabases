CREATE PROCEDURE [dbo].[Usp_ReportPointsAwardStatementData] 
	@customerId bigint,
	@agreementId bigint,
	@StartDate Datetime,
	@EndDate Datetime,
	@accountId bigint
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
	RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' '  + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS Customer,
	SC.CardSNO AS Mask,CV.EquipmentRegNo  AS Equipment,0 AS Debit,RewardAmount AS Credit,CA.AccountNumber,RewardAmount As Balance 
	into #temptable 
	FROM LRResults AS LRR
	INNER JOIN LRADataInputs AS DI ON DI.LRADataInputId = LRR.LRADataInputId
	INNER JOIN SystemTickets T ON T.FinanceTransactionId=DI.FinanceTransactionId
	INNER JOIN  CustomerVehicleUsages FMU ON FMU.TicketId=T.TicketId
	INNER JOIN CustomerEquipments CV ON CV.EquipmentId=FMU.EquipmentId
	INNER JOIN LTransactionTypes AS LT ON LT.LTransactionTypeId = LRR.LTransactionTypeId
	INNER JOIN CustomerAccount AS CA ON CA.AccountId = LRR.AccountId
	INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
	INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
	INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
	INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
	WHERE LRR.LTransactionTypeId = (SELECT LTransactionTypeId FROM LTransactionTypes Where LTransactionTypeName = 'Award')
	AND LRR.LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
	AND LRR.AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = @agreementId)
	AND LRR.DateCreated BETWEEN @StartDate AND (dateadd(day,1,@EndDate)) 


insert into #temptable 

SELECT LRR.DateCreated AS Date,LT.LTransactionTypeName AS Description,
RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) AS Customer,
(SELECT TOP 1 CardSNO FROM Systemcard Where CardId in (SELECT CardId FROM SystemAccountCards Where AccountId = (SELECT AccountId FROM CustomerAccount Where AccountNumber = CA.AccountNumber ))AND TagTypeId in (SELECT TOP 1 TagtypeId FROM Systemcardtype Where TagTypename in ('Card','Tag')) ) AS Mask
,CV.EquipmentRegNo  AS Equipment,RewardAmount AS Debit,0 AS Credit,CA.AccountNumber,RewardAmount As Balance 
FROM LRResults AS LRR
INNER JOIN LRADataInputs AS DI ON DI.LRADataInputId = LRR.LRADataInputId
INNER JOIN SystemTickets T ON T.FinanceTransactionId=DI.FinanceTransactionId
INNER JOIN  CustomerVehicleUsages FMU ON FMU.TicketId=T.TicketId
INNER JOIN CustomerEquipments CV ON CV.EquipmentId=FMU.EquipmentId
INNER JOIN LTransactionTypes AS LT ON LT.LTransactionTypeId = LRR.LTransactionTypeId
INNER JOIN CustomerAccount AS CA ON CA.AccountId = LRR.AccountId
INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
WHERE LRR.LTransactionTypeId = (SELECT LTransactionTypeId FROM LTransactionTypes Where LTransactionTypeName = 'Conversion')
AND LRR.LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
AND LRR.AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = @agreementId)
AND LRR.DateCreated BETWEEN @StartDate AND (dateadd(day,1,@EndDate)) 


declare @openingBalance float = 0;

if(@accountId < 1)
BEGIN 
    set @openingBalance = (SELECT SUM(RewardAmount) AS Rewards FROM LRResults Where LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
                           AND AccountId in (SELECT AccountId FROM CustomerAccount Where AgreementId = @agreementId)
                           AND DateCreated <= @StartDate
                           Group By AccountId);
END
ELSE If(@accountId > 1)
BEGIN
    set @openingBalance  = (SELECT SUM(RewardAmount) AS Rewards FROM LRResults Where LRewardId = (SELECT LRewardId FROM LRewards Where RewardName = 'Points')
                           AND AccountId = @accountId
                           AND DateCreated <= @StartDate);

END


INSERT INTO #temptable
SELECT @StartDate AS Date,'Opening Balance' AS Description,'' AS Customer,'' AS Mask,'' AS Equipment,0  AS Debit,IsNull(@openingBalance,0) AS Credit,0 AS AccountNumber,IsNull(@openingBalance,0) AS Balance



select Date,Description,Customer,Mask,Equipment,Debit,Credit,AccountNumber,+ SUM(Balance) OVER (ORDER BY Date) AS Balance from #temptable;

drop table #temptable

end
