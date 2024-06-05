CREATE PROCEDURE [dbo].[Usp_ReportCustomerTopupData] 
    @JsonObjectdata VARCHAR(MAX) OUTPUT,
    @CustomerTopUpDataDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;

    -- Create a temporary table to store the intermediate results
    CREATE TABLE #TempCustomerTopUpData
    (
        TopUpDate datetime2(6),
        DateCreated datetime2(6),
        Reference NVARCHAR(MAX),
        TransactionCode NVARCHAR(MAX),
        Station NVARCHAR(MAX),
        Attendant NVARCHAR(MAX),
        Mask NVARCHAR(MAX),
        AccountNumber NVARCHAR(MAX),
        Identifier NVARCHAR(MAX),
        TopupMode NVARCHAR(MAX),
        Amount DECIMAL(18, 2),
        Description NVARCHAR(MAX),
        Customer NVARCHAR(MAX)
    );

    -- Insert data into the temporary table
    INSERT INTO #TempCustomerTopUpData
    SELECT 
        B.ActualDate AS TopUpDate,
        B.DateCreated,
        A.Topupreference AS Reference,
        B.TransactionCode AS TransactionCode,
        ISNULL(F.Sname, 'N/A') AS Station,
        s.Fullname AS Attendant,
        COALESCE(cd.cardSNO, 'N/A') AS Mask,
        C.AccountNumber,
        'Mask: N/A ,'+ 'Account:' + CAST(C.AccountNumber AS VARCHAR(30)) AS Identifier,
        U.Paymentmode AS TopupMode,
        A.Amount,
        B.Saledescription AS Description,
        RTRIM(LTRIM(ISNULL(E.FirstName, '') + ' ' + ISNULL(E.LastName, '') + ISNULL(E.CompanyName, ''))) AS Customer
    FROM CustomerAccountTopups A
    LEFT JOIN FinanceTransactions B ON B.FinanceTransactionId = A.FinanceTransactionId
    LEFT JOIN CustomerAccount C ON A.AccountId = C.AccountId
    LEFT JOIN CustomerAgreements D ON D.AgreementId = C.AgreementId
    LEFT JOIN SystemAccountCards AS cac ON cac.accountId = C.AccountId
    LEFT JOIN Systemcard AS cd ON cd.CardId = cac.cardid
    LEFT JOIN Customers E ON E.CustomerId = D.CustomerId
    LEFT JOIN SystemStations F ON F.Tenantstationid = A.Stationid 
    LEFT JOIN SystemStaffs S ON S.UserId = A.StaffId
		INNER JOIN Paymentmodes U ON A.ModeofPayment=U.PaymentmodeId
    WHERE (JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 OR E.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer')) 
        AND (JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 OR D.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))  
        AND (JSON_VALUE(@JsonObjectdata, '$.Account') < 1 OR C.AccountId = JSON_VALUE(@JsonObjectdata, '$.Account')) 
        AND B.ActualDate > TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) 
        AND B.ActualDate <= DATEADD(day, 1, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 
        AND C.ParentId>0
    UNION 
    SELECT 
        B.ActualDate AS TopUpDate,
        B.DateCreated,
        A.Topupreference AS Reference,
        B.TransactionCode AS TransactionCode,
        ISNULL(F.Sname, 'N/A') AS Station,
        s.Fullname AS Attendant,
        cd.CardSNO AS Mask,
        C.AccountNumber,
        'Mask:' + cd.CardSNO + ','+ 'Account:' + CAST(C.AccountNumber AS VARCHAR(30)) AS Identifier,
        U.Paymentmode AS TopupMode,
        A.Amount,
        B.Saledescription AS Description,
        RTRIM(LTRIM(ISNULL(E.FirstName, '') +  ' ' + ISNULL(E.LastName, '') + ISNULL(E.CompanyName, ''))) AS Customer
    FROM CustomerAccountTopups A
    LEFT JOIN FinanceTransactions B ON B.FinanceTransactionId = A.FinanceTransactionId
    LEFT JOIN CustomerAccount C ON A.AccountId = C.AccountId
    LEFT JOIN CustomerAgreements D ON D.AgreementId = C.AgreementId
    LEFT JOIN SystemAccountCards AS cac ON cac.accountId = C.AccountId
    LEFT JOIN Systemcard AS cd ON cd.CardId = cac.cardid
    LEFT JOIN Customers E ON E.CustomerId = D.CustomerId
    LEFT JOIN SystemStations F ON F.Tenantstationid = A.Stationid 
    LEFT JOIN SystemStaffs S ON S.UserId = A.StaffId
	INNER JOIN Paymentmodes U ON A.ModeofPayment=U.PaymentmodeId
    WHERE (JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 OR E.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer')) 
        AND (JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 OR D.AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))  
        AND (JSON_VALUE(@JsonObjectdata, '$.Account') < 1 OR C.AccountId = JSON_VALUE(@JsonObjectdata, '$.Account')) 
        AND B.ActualDate > TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) 
        AND B.ActualDate <= DATEADD(day, 1, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)))
        AND cd.tagtypeid = (SELECT TagtypeId FROM Systemcardtype WHERE TagTypename = 'Card') 
    ORDER BY DateCreated DESC;

    -- Retrieve data from the temporary table and assign it to the output variable
    SELECT @CustomerTopUpDataDetailsJson = (
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
		   (SELECT TopUpDate, DateCreated,Reference,TransactionCode,Station, Attendant,Mask,AccountNumber,Identifier,TopupMode,Amount,Description, Customer FROM #TempCustomerTopUpData   FOR JSON PATH
			) AS CustomerTopupData
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );

    -- Drop the temporary table
    DROP TABLE IF EXISTS #TempCustomerTopUpData;
END