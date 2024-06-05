CREATE PROCEDURE [dbo].[Usp_ReportPrepaidCustomerStatementData]
@JsonObjectdata VARCHAR(MAX) OUTPUT,
@CustomerPrepaidStatementDetailsJson VARCHAR(MAX) OUTPUT
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
--sales
select CA.AccountId, CA.AccountNumber,P.AgreementId as CustomerAgreementId,  A.ActualDate AS TransactionDate, A.DateCreated AS PostingDate, A.TransactionCode, A.Saledescription As MEMO, E.Sname as Station,
('Mask: '+SC.CardSNO+' Eqp: '+IsNull(k.EquipmentRegNo,'N/A')) as Mask, k.EquipmentRegNo as Equipment,  
F.Units AS QTY, F.Price, H.Productvariationname as Product, F.Discount, -(I.TotalUsed) as TotalAmount, I.TotalUsed as Debit, 0 as Credit, -1*(I.TotalUsed) AS Balance ,1 As Sort
into #temptable 
from FinanceTransactions A 
inner join SystemTickets B on A.FinanceTransactionId = B.FinancetransactionId
left join CustomerVehicleUsages u on u.TicketId = B.TicketId
left join CustomerEquipments k on u.EquipmentId = k.EquipmentId
INNER JOIN CustomerAccount AS CA ON CA.AccountId = B.AccountId
INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
inner join CustomerAgreements P on P.AgreementId = CA.AgreementId
inner join TicketLines F on B.TicketId = F.TicketId
inner join TicketlinePayments I on I.TicketId = B.TicketId
inner join SystemProductvariation H on F.ProductvariationId = H.ProductvariationId
inner join SystemStations E on E.Tenantstationid = B.StationId
where (JSON_VALUE(@JsonObjectdata, '$.Customer')<1 OR P.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer')) and A.ActualDate >= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) and A.ActualDate < dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
and (P.AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))and (B.AccountId in (select AccountId from CustomerAccount Where AgreementId  = JSON_VALUE(@JsonObjectdata, '$.Agreement')))
and
I.PaymentModeId = (SELECT PaymentmodeId FROM PaymentModes WHERE Paymentmode = 'Card');

--topups
insert into #temptable 
select Z.AccountId, Z.AccountNumber,Z.AgreementId AS  CustomerAgreementId, A.ActualDate AS TransactionDate, A.DateCreated AS PostingDate, A.TransactionCode, A.Saledescription AS Memo, E.Sname as Station, 'NA' as Mask, 'NA' as Equipment, 
0 as QTY, 0 as Price, 'NA' as Product, 0 as Discount, Amount as TotalAmount, 0 as Debit, Amount as credit,Amount AS Balance,1 As Sort
from CustomerAccountTopups B
left join FinanceTransactions A on A.FinanceTransactionId = B.FinancetransactionId
left join CustomerAccount Z on Z.AccountId = B.AccountId 
INNER JOIN CustomerAgreements AG ON Z.AgreementId=AG.AgreementId
left join SystemStations E on E.Tenantstationid = B.StationId
where (JSON_VALUE(@JsonObjectdata, '$.Customer')<1 OR AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer')) 
and A.ActualDate >= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) and  A.ActualDate <dateadd(day,1, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
and (z.AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement')) 
and (z.AccountNumber in (select AccountNumber from CustomerAccount Where AgreementId  = JSON_VALUE(@JsonObjectdata, '$.Agreement')))


IF(JSON_VALUE(@JsonObjectdata, '$.Account')>0)
begin
delete from #tempTable where AccountId != JSON_VALUE(@JsonObjectdata, '$.Account'); 
end

declare @openingBalance float = 0;

if(JSON_VALUE(@JsonObjectdata, '$.Account') <= 1)
BEGIN 

 set @openingBalance = (select sum(amount) from GLTransactions 
 LEFT JOIN FinanceTransactions ON FinanceTransactions.FinanceTransactionId=GLTransactions.FinanceTransactionId
 where ChartofAccountid  in (select ChartofAccountId from chartofAccounts where ChartofAccountname in
	(select CONVERT(VARCHAR, AccountNumber) from CustomerAccount INNER JOIN CustomerAgreements ON CustomerAccount.AgreementId=CustomerAgreements.AgreementId where customerId = JSON_VALUE(@JsonObjectdata, '$.Customer') and CustomerAgreements.AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement') AND CredittypeId = (SELECT CredittypeId FROM CreditTypes WHERE Credittypevalue=0)))
	and FinanceTransactions.ActualDate <= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))
	);

	set @openingBalance = -1 * @openingBalance;
END
ELSE If(JSON_VALUE(@JsonObjectdata, '$.Account') > 1)
BEGIN
    set @openingBalance  = (
	select sum(amount) from GLTransactions  LEFT JOIN FinanceTransactions ON FinanceTransactions.FinanceTransactionId=GLTransactions.FinanceTransactionId where ChartofAccountid  = (select ChartofAccountId from chartofAccounts where ChartofAccountname = (SELECT CONVERT(VARCHAR, AccountNumber) FROM CustomerAccount WHERE AccountId=JSON_VALUE(@JsonObjectdata, '$.Account')))
	and FinanceTransactions.ActualDate <= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) );

END


INSERT INTO #temptable
SELECT 0 AS  AccountId,0 AS AccountNumber, JSON_VALUE(@JsonObjectdata, '$.Agreement') AS CustomerAgreementId,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS TransactionDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS PostingDate,'N/A' AS TransactionCode,'Opening Balance' AS Memo,'N/A' AS Mask,'N/A' AS Station,'N/A' AS Equipment,
0 AS QTY,0 AS Price,'N/A' AS Product,0 AS Discount,@openingBalance AS TotalAmount,0 AS Debit,0 AS Credit,@openingBalance AS Balance,0 AS Sort




 SELECT @CustomerPrepaidStatementDetailsJson = (
	     SELECT 
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 THEN 'ALL' ELSE (SELECT RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) FROM Customers C WHERE C.CustomerId=JSON_VALUE(@JsonObjectdata, '$.Customer')) END)AS CustomerName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 THEN 'ALL' ELSE (SELECT  TA.Agreementtypename FROM CustomerAgreements CA INNER JOIN AgreementTypes TA ON CA.AgreemettypeId=TA.AgreemettypeId INNER JOIN CustomerAccount AC ON AC.AgreementId=CA.AgreementId WHERE CA.AgreementId=JSON_VALUE(@JsonObjectdata, '$.Agreement') AND AC.ParentId=0) END)AS AgreementName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.Tenantstationid=JSON_VALUE(@JsonObjectdata, '$.Station')) END)AS StationName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Paymode') < 1 THEN 'ALL' ELSE (SELECT PM.Paymentmode FROM Paymentmodes PM WHERE PM.PaymentmodeId=JSON_VALUE(@JsonObjectdata, '$.Paymode')) END)AS PaymentModeName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Account') < 1 THEN 'ALL' ELSE (SELECT CS.CardSNO FROM CustomerAccount CA INNER JOIN SystemAccountCards SC ON SC.AccountId=CA.AccountId INNER JOIN Systemcard CS ON CS.CardId=SC.CardId WHERE CA.AccountId=JSON_VALUE(@JsonObjectdata, '$.Account')) END)AS AccountName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT ST.Fullname FROM SystemStaffs ST WHERE ST.StaffId=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END)AS AttendantName,
		    (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Product') < 1 THEN 'ALL' ELSE (SELECT SP.Productvariationname FROM SystemProductvariation SP WHERE SP.ProductvariationId=JSON_VALUE(@JsonObjectdata, '$.Product')) END)AS ProductName,
		   (select CustomerAgreementId,TransactionDate,PostingDate,TransactionCode,Memo,Mask,Station,Equipment,
				QTY,Price,Product,Discount,TotalAmount,Debit,Credit, SUM(Balance) OVER (ORDER BY TransactionDate) AS Balance  from #temptable
				order by TransactionDate,Sort asc FOR JSON PATH
			) AS CustomerPrepaidStatementData
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );

drop table #temptable

end