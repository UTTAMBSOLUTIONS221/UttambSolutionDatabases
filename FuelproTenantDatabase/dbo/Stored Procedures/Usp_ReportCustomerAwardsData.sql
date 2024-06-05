CREATE PROCEDURE [dbo].[Usp_ReportCustomerAwardsData]
	@JsonObjectdata VARCHAR(MAX) OUTPUT,
	@PointAwardDataDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN

declare @rewardId bigint = (SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points');
declare @awardId bigint = (SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award');
declare @awardId1 bigint = (SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse');
  -- Create a temporary table to store the intermediate results
    CREATE TABLE #TempCustomerPointAwardData
    (
        Product NVARCHAR(MAX),
		SaleValue DECIMAL(18, 2),
		AwardValue DECIMAL(18, 2),
        Station NVARCHAR(MAX),
		Attendant NVARCHAR(MAX),
        AccountCreditType NVARCHAR(MAX),
		TransactionDate datetime2(6),
		Account NVARCHAR(MAX),
        Customer NVARCHAR(MAX),
        AccountNumber NVARCHAR(MAX),
        IDNumber NVARCHAR(MAX),
		Units DECIMAL(18, 2),
		Price DECIMAL(18, 2)
    );


IF (JSON_VALUE(@JsonObjectdata, '$.Attendant') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Station') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Customer') = 0)
	BEGIN
	--Points Awards
	    -- Insert data into the temporary table
  INSERT INTO #TempCustomerPointAwardData
  SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE  R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
  SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
  ORDER BY R.DateCreated ASC
		RETURN
	END

IF (JSON_VALUE(@JsonObjectdata, '$.Attendant') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Station') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Customer') > 0)
BEGIN
   --Points Awards
 INSERT INTO #TempCustomerPointAwardData
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
  ORDER BY R.DateCreated ASC
	RETURN
END

IF (JSON_VALUE(@JsonObjectdata, '$.Attendant') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Station')  > 0 AND JSON_VALUE(@JsonObjectdata, '$.Customer') = 0)
	BEGIN

	   --Points Awards
 INSERT INTO #TempCustomerPointAwardData
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
  SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
  ORDER BY R.DateCreated ASC

		
		RETURN
	END

IF (JSON_VALUE(@JsonObjectdata, '$.Attendant') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Station') > 0 AND JSON_VALUE(@JsonObjectdata, '$.Customer') > 0)
	BEGIN
		   --Points Awards
 INSERT INTO #TempCustomerPointAwardData
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
  SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
  ORDER BY R.DateCreated ASC

		RETURN
	END

IF (JSON_VALUE(@JsonObjectdata, '$.Attendant') > 0 AND JSON_VALUE(@JsonObjectdata, '$.Station') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Customer') = 0)
	BEGIN
			   --Points Awards
 INSERT INTO #TempCustomerPointAwardData
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE DI.Createdby = JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
  SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE DI.Createdby = JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
  ORDER BY R.DateCreated ASC

		
		RETURN
	END

IF (JSON_VALUE(@JsonObjectdata, '$.Attendant') > 0 AND JSON_VALUE(@JsonObjectdata, '$.Station') = 0 AND JSON_VALUE(@JsonObjectdata, '$.Customer') > 0)

	BEGIN
			   --Points Awards
 INSERT INTO #TempCustomerPointAwardData
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND DI.Createdby =  JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
  SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND DI.Createdby =  JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))

  ORDER BY R.DateCreated ASC

	
		RETURN
	END

IF (JSON_VALUE(@JsonObjectdata, '$.Station') > 0 AND JSON_VALUE(@JsonObjectdata, '$.Attendant') > 0 AND JSON_VALUE(@JsonObjectdata, '$.Customer') = 0)
	BEGIN

				   --Points Awards
INSERT INTO #TempCustomerPointAwardData
SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND DI.Createdby = JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
  SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND DI.Createdby = JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
  
  ORDER BY R.DateCreated ASC
	 
		RETURN
	END

ELSE
	BEGIN
				   --Points Awards
 INSERT INTO #TempCustomerPointAwardData
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND DI.Createdby = JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Award')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 

  UNION

--Point Reversals
   	
 SELECT SP.Productvariationname AS Product, PYMT.TotalUsed AS SaleValue, R.RewardAmount AS AwardValue, S.Sname AS Station, STF.Fullname As Attendant, CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END AS AccountCreditType, R.DateCreated AS TransactionDate, COALESCE(SC.CardSNO,'N/A') AS Account, CA.AccountNumber, UPPER(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, '')))) AS Customer, 
   C.IDNumber, TL.Units, TL.Price
  FROM LRResults R
  INNER JOIN LRADataInputs DI ON R.LRADataInputId=DI.LRADataInputId 
  INNER JOIN SystemTickets AS TKT ON TKT.FinanceTransactionId = DI.FinanceTransactionId 
  INNER JOIN TicketLines TL ON TL.TicketId =TKT.TicketId
  INNER JOIN TicketlinePayments As PYMT ON PYMT.ticketId = TKT.TicketId 
  INNER JOIN SystemProductvariation SP ON TL.ProductvariationId=SP.ProductvariationId
  INNER JOIN SystemStations S ON S.Tenantstationid = TKT.StationId 
  INNER JOIN SystemStaffs AS STF ON STF.UserId = TKT.StaffId 
  INNER JOIN CustomerAccount AS CA ON CA.AccountId = R.AccountId
  INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
  INNER JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
  INNER JOIN Systemcard SC ON SAC.CardId=SC.CardId
  INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
  INNER JOIN Customers AS C ON C.CustomerId = AG.CustomerId
  WHERE AG.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer') AND DI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station') AND DI.Createdby = JSON_VALUE(@JsonObjectdata, '$.Attendant') AND R.LRewardId=(SELECT top 1 LRewardId FROM LRewards  WHERE RewardName='Points')  AND R.LTransactionTypeId=(SELECT top 1 LTransactionTypeId FROM LTransactionTypes  WHERE LTransactionTypeName='Reverse')
  AND R.DateCreated BETWEEN Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))) AND Convert(datetime,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
  ORDER BY R.DateCreated ASC

		RETURN
	END
	SELECT @PointAwardDataDetailsJson = (
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
		   (SELECT Product,SaleValue,AwardValue,Station,Attendant,AccountCreditType,TransactionDate,Account,Customer,AccountNumber,IDNumber,Units,Price FROM #TempCustomerPointAwardData   FOR JSON PATH
			) AS CustomerPointRewardData
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );

    -- Drop the temporary table
    DROP TABLE IF EXISTS #TempCustomerPointAwardData;
END