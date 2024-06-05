CREATE PROCEDURE [dbo].[Usp_ReportPostPaidCustomerStatementData]
@JsonObjectdata VARCHAR(MAX) OUTPUT,
@PostPaidCustomerStatementDataDetailsJson VARCHAR(MAX) OUTPUT
as
begin
SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END  
      declare @openingBalance float = 0;
      
      declare @agreementTypeName nvarchar(30) = (SELECT top 1 Agreementtypename FROM AgreementTypes Where AgreemettypeId =(SELECT top 1 AgreemettypeId FROM CustomerAgreements Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement')))

      if(@agreementTypeName != 'Credit' and @agreementTypeName !='Purchase-Order')
      BEGIN
      

select  K.AgreementId as CustomerAgreementId, A.ActualDate, A.DateCreated, A.TransactionCode, A.Saledescription AS description, E.Sname as Station, ('Mask: '+SC.CardSNO+' Eqp: '+IsNull(ko.EquipmentRegNo,'N/A')) as Mask, ko.EquipmentRegNo as Equipment,
F.Units, F.Price, H.Productvariationname as Product, F.Discount, ((F.Price*F.Units)-F.Discount) as TotalAmount, I.TotalUsed,-1*(I.TotalUsed) AS Balance,1 AS Sort
into #tempTable
from FinanceTransactions A
inner join SystemTickets B on A.FinanceTransactionId = B.FinancetransactionId
left join CustomerVehicleUsages u on u.TicketId = B.TicketId
left join CustomerEquipments ko on u.EquipmentId = ko.EquipmentId
INNER JOIN CustomerAccount CA ON B.AccountId=CA.AccountId
INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
inner join CustomerAgreements K on K.AgreementId = CA.AgreementId
inner join Customers J on J.CustomerId = K.CustomerId
inner join TicketLines F on B.TicketId = F.TicketId
inner join TicketlinePayments I on I.TicketId = B.TicketId
inner join SystemProductvariation H on F.ProductvariationId = H.ProductvariationId
inner join SystemStations E on E.Tenantstationid = B.StationId
where A.ActualDate >= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) and A.ActualDate <= dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))  and (JSON_VALUE(@JsonObjectdata, '$.Customer')=-1 OR K.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer'))
AND I.PaymentModeId = (SELECT TOP 1 PaymentId FROM PaymentModes where Paymentmode = 'Card')
AND B.AccountId In (SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
--order by A.ActualDate asc


INSERT INTO #tempTable
SELECT  CP.AgreementId,FT.ActualDate,FT.Datecreated,FT.TransactionCode,FT.Saledescription AS Description,'N/A' AS Station,'N/A' AS Mask,'N/A' AS Equipment,
0 AS Units,0 AS Price,'N/A' AS Product,0 AS Discount,CP.Amount AS TotalAmount,CP.Amount AS TotalUsed,CP.Amount AS Balance,1 AS Sort
FROM CustomerPayments AS CP
LEFT JOIN FinanceTransactions AS FT ON FT.FinanceTransactionId = CP.financeTransactionId
LEFT JOIN CustomerAgreements AS CA ON CA.AgreementId = CP.AgreementId
where FT.ActualDate >= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) and FT.ActualDate <= dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))  and (JSON_VALUE(@JsonObjectdata, '$.Customer')=-1 OR CA.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer'))
--order by FT.ActualDate asc


IF(JSON_VALUE(@JsonObjectdata, '$.Agreement')>0)
begin
delete from #tempTable where CustomerAgreementId !=  JSON_VALUE(@JsonObjectdata, '$.Agreement'); --  from #tempTRANSACTIONS where
end

Declare @totalSales float =  ((SELECT sum(TotalUsed) FROM SystemTickets AS TKT
LEFT JOIN FinanceTransactions AS FT ON FT.FinanceTransactionId = TKT.FinanceTransactionId
LEFT JOIN TicketlinePayments AS PYMT On PYMT.TicketId = TKT.TicketId
Where AccountId in
(SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
AND FT.ActualDate <= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND PYMT.PaymentModeId = (SELECT TOP 1 PaymentmodeId FROM PaymentModes where Paymentmode = 'Card')) * -1)


Declare @totalPayments float = (SELECT sum(amount) FROM CustomerPayments AS FCP
LEFT JOIN FinanceTransactions AS FT ON FT.FinanceTransactionId = FCP.FinanceTransactionId
Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement')
AND FT.ActualDate <= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)))

SET @openingBalance= (SELECT @totalSales + @totalPayments);

INSERT INTO #tempTable
SELECT JSON_VALUE(@JsonObjectdata, '$.Agreement') AS CustomerAgreementId,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS ActualDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS Datecreated, 'N/A' AS TransactionCode,'Opening Balance' AS Description, 'NA' AS Station,
'N/A' AS Mask, 'N/A' AS Equipment, 0 AS Units,0 AS Price,'N/A' AS Product,0 AS Discount, @openingBalance AS TotalAmount,@openingBalance AS TotalUsed,@openingBalance AS Balance,0 AS Sort

--SELECT *  from #tempTable order by ActualDate asc;


SELECT CustomerAgreementId,ActualDate,Datecreated,TransactionCode,Description,Station,Mask,Equipment,
 Units,Price,Product,Discount,TotalAmount,TotalUsed,(0) + SUM(Balance) OVER (ORDER BY ActualDate) AS Balance,Sort
 from #tempTable WHERE TransactionCode not like '%-%' order by ActualDate,sort asc

 END
 ELSE If(@agreementTypeName ='Credit')
 BEGIN
 --drop table #tempTable

 select  K.AgreementId as CustomerAgreementId, A.ActualDate, A.DateCreated, A.TransactionCode, A.Saledescription AS description, E.Sname as Station, ('Mask: '+SC.CardSNO+' Eqp: '+IsNull(ko.EquipmentRegNo,'N/A')) as Mask, ko.EquipmentRegNo as Equipment,
F.Units, F.Price, H.Productvariationname as Product, F.Discount, ((F.Price*F.Units)-F.Discount) as TotalAmount, I.TotalUsed,-1*(I.TotalUsed) AS Balance,1 AS Sort
into #tempTable2
from FinanceTransactions A
inner join SystemTickets B on A.FinanceTransactionId = B.FinancetransactionId
left join CustomerVehicleUsages u on u.TicketId = B.TicketId
left join CustomerEquipments ko on u.EquipmentId = ko.EquipmentId
INNER JOIN CustomerAccount CA ON B.AccountId=CA.AccountId
INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
inner join CustomerAgreements K on K.AgreementId = CA.AgreementId
inner join Customers J on J.CustomerId = K.CustomerId
inner join TicketLines F on B.TicketId = F.TicketId
inner join TicketlinePayments I on I.TicketId = B.TicketId
inner join SystemProductvariation H on F.ProductvariationId = H.ProductvariationId
inner join SystemStations E on E.Tenantstationid = B.StationId
where A.ActualDate >= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) and A.ActualDate <= dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))  and (JSON_VALUE(@JsonObjectdata, '$.Customer')=-1 OR K.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer'))
AND I.PaymentModeId = (SELECT TOP 1 PaymentId FROM PaymentModes where Paymentmode = 'Card')
AND B.AccountId In (SELECT AccountId FROM CustomerAccount Where AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
--order by A.ActualDate asc



INSERT INTO #tempTable2
SELECT  CP.AgreementId AS CustomerAgreementId,FT.ActualDate,FT.Datecreated,FT.TransactionCode,FT.Saledescription  AS Description,'N/A' AS Station,'N/A' AS Mask,'N/A' AS Equipment,
0 AS Units,0 AS Price,'N/A' AS Product,0 AS Discount,CP.Amount AS TotalAmount,CP.Amount AS TotalUsed,CP.Amount AS Balance,1 AS Sort
FROM CustomerPayments AS CP
LEFT JOIN FinanceTransactions AS FT ON FT.FinanceTransactionId = CP.financeTransactionId
LEFT JOIN CustomerAgreements AS CA ON CA.AgreementId = CP.AgreementId
where  FT.ActualDate >= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) and FT.ActualDate <= dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))  and (JSON_VALUE(@JsonObjectdata, '$.Customer')=-1 OR CA.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer'))
--order by FT.ActualDate asc


IF(JSON_VALUE(@JsonObjectdata, '$.Agreement')>0)
begin
delete from #tempTable2 where CustomerAgreementId !=  JSON_VALUE(@JsonObjectdata, '$.Agreement'); --  from #tempTRANSACTIONS where
end



declare @tS float = (select Sum(amount) as Total from GLTransactions AS GL LEFT JOIN financeTransactions AS FT ON FT.FinanceTransactionId =  GL.FinanceTransactionId
      where ChartofAccountId in (select ChartofAccountId from ChartofAccounts where ChartofAccountname in (SELECT cast(AccountNumber as varchar(30)) FROM CustomerAccount
       WHERE AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement')
       AND CredittypeId = (SELECT CredittypeId FROM CreditTypes WHERE Credittypevalue=1)  AND FT.ActualDate >='2022-02-01 00:00:00.000' AND FT.ActualDate<=TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) --FT.ActualDate <='2022-02-01 00:00:00.000'
       )))


SET @openingBalance= (SELECT @tS * -1);

INSERT INTO #tempTable2
SELECT JSON_VALUE(@JsonObjectdata, '$.Agreement') AS CustomerAgreementId,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS ActualDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS Datecreated, 'N/A' AS TransactionCode,'Opening Balance' AS Description, 'NA' AS Station,
'N/A' AS Mask, 'N/A' AS Equipment , 0 AS Units,0 AS Price,'N/A' AS Product,0 AS Discount, @openingBalance AS TotalAmount,@openingBalance AS TotalUsed,@openingBalance AS Balance,0 AS Sort

--SELECT *  from #tempTable order by ActualDate asc;



 SELECT @PostPaidCustomerStatementDataDetailsJson = (
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
		   (
			SELECT CustomerAgreementId,ActualDate,Datecreated,TransactionCode,Description,Station,Mask,Equipment,
			 Units,Price,Product,Discount,TotalAmount,TotalUsed,(0) + SUM(Balance) OVER (ORDER BY Datecreated) AS Balance,Sort
			 from #tempTable2 WHERE TransactionCode not like '%-%' order by Datecreated,sort asc  FOR JSON PATH
			) AS PostPaidCustomerStatementData
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );

 END
--drop table #temptTable;

end