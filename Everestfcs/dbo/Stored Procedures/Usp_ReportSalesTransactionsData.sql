CREATE PROCEDURE [dbo].[Usp_ReportSalesTransactionsData]
	@JsonObjectdata VARCHAR(MAX) OUTPUT,
	@FinanceTransactionDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    WITH FinanceTransactions AS
    (
        SELECT
            FinancetransactionId, 
			TenantId,
            transactioncode, 
            Saledescription, 
            ActualDate, 
            DateCreated, 
            SaleRefence, 
            ParentId, 
            Saletransactiontype, 
            AutomationRefence,
            10 * FinancetransactionId AS orderKey
        FROM VWFinanceTransactions
        WHERE ParentId = 0

        UNION ALL

        SELECT
            FinancetransactionId, 
			TenantId,
            transactioncode, 
            Saledescription, 
            ActualDate, 
            DateCreated, 
            SaleRefence, 
            ParentId, 
            Saletransactiontype, 
            AutomationRefence,
            10 * ParentId + 1 AS orderKey
        FROM VWFinanceTransactions
        WHERE ParentId != 0
    )

    -- Construct the JSON result
    SELECT
        @FinanceTransactionDetailsJson = (
        SELECT 
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 THEN 'ALL' ELSE (SELECT RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) FROM Customers C WHERE C.CustomerId=JSON_VALUE(@JsonObjectdata, '$.Customer')) END)AS CustomerName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 THEN 'ALL' ELSE (SELECT  TA.Agreementtypename FROM CustomerAgreements CA INNER JOIN AgreementTypes TA ON CA.AgreemettypeId=TA.AgreemettypeId INNER JOIN CustomerAccount AC ON AC.AgreementId=CA.AgreementId WHERE CA.AgreementId=JSON_VALUE(@JsonObjectdata, '$.Agreement') AND AC.ParentId=0) END)AS AgreementName,
			'' AS GroupName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END)AS StationName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Paymode') < 1 THEN 'ALL' ELSE (SELECT PM.Paymentmode FROM Paymentmodes PM WHERE PM.PaymentmodeId=JSON_VALUE(@JsonObjectdata, '$.Paymode')) END)AS PaymentModeName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Account') < 1 THEN 'ALL' ELSE (SELECT CS.CardSNO FROM CustomerAccount CA INNER JOIN SystemAccountCards SC ON SC.AccountId=CA.AccountId INNER JOIN Systemcard CS ON CS.CardId=SC.CardId WHERE CA.AccountId=JSON_VALUE(@JsonObjectdata, '$.Account')) END)AS AccountName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT ST.Firstname +' '+ ST.Lastname AS Fullname FROM SystemStaffs ST WHERE ST.UserId=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END)AS AttendantName,
		    (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Product') < 1 THEN 'ALL' ELSE (SELECT SP.Productvariationname FROM SystemProductvariation SP WHERE SP.ProductvariationId=JSON_VALUE(@JsonObjectdata, '$.Product')) END)AS ProductName,
		   (
            SELECT
                A.ActualDate AS TransactionDate,
                A.DateCreated AS PostingDate,
                A.TransactionCode,
                A.AutomationRefence,
                A.parentid,
                A.orderKey,
                L.Sname AS Station,
                ISNULL(C.Firstname+' '+C.Lastname, '') AS Attendant,
                CASE WHEN D.Designation = 'Individual' THEN ISNULL(D.FirstName, '') + ' ' + ISNULL(D.LastName, '') ELSE D.CompanyName END AS Customer,
                '' AS Groupname,
                CA.AccountNumber,
                COALESCE(SC.CardSNO, 'Not Set') AS Mask,
                k.EquipmentRegNo AS Equipment,
                LEFT(pa.PayMode, LEN(pa.PayMode) - 0) AS PayMode,
                LEFT(tl.Products, LEN(tl.Products) - 0) AS Products,
                LEFT(tu.Units, LEN(tu.Units) - 0) AS Units,
                LEFT(tp.Price, LEN(tp.Price) - 0) AS Price,
                LEFT(td.Discount, LEN(td.Discount) - 0) AS Discount,
                LEFT(py.SaleAmount, LEN(py.SaleAmount) - 0) AS SaleAmount,
                (SELECT SUM(t.Units) FROM TicketLines t WHERE t.TicketId = b.TicketId) AS Sumunits,
                (SELECT SUM(t.Discount) FROM TicketLines t WHERE t.TicketId = b.TicketId) AS Sumdiscount,
                H.TotalUsed AS Sumsalesamount
            FROM FinanceTransactions A
            INNER JOIN SystemTickets B ON A.FinancetransactionId = B.FinanceTransactionId
            INNER JOIN TicketLines TickL ON B.TicketId = TickL.TicketId
            LEFT JOIN CustomerVehicleUsages u ON u.TicketId = B.TicketId
            LEFT JOIN CustomerEquipments k ON u.EquipmentId = k.EquipmentId
            LEFT JOIN TicketlinePayments H ON H.TicketId = B.TicketId
            LEFT JOIN PaymentModes I ON I.PaymentmodeId = H.PaymentModeId
            LEFT JOIN SystemStaffs C ON B.StaffId = C.UserId
            LEFT JOIN SystemStations L ON B.stationId = L.StationId
            LEFT JOIN CustomerAccount CA ON B.AccountId = CA.AccountId
            LEFT JOIN CustomerAgreements AG ON AG.AgreementId = CA.AgreementId
            LEFT JOIN Customers D ON AG.CustomerId = D.CustomerId
            LEFT JOIN SystemAccountCards SAC ON CA.AccountId = SAC.AccountId
            LEFT JOIN Systemcard SC ON SAC.CardId = SC.CardId
            CROSS APPLY (
                SELECT 
                    STUFF(
                        (
                            SELECT ', ' + p.Productvariationname
                            FROM TicketLines tl
                            INNER JOIN SystemProductvariation p ON P.ProductvariationId = tl.ProductVariationId
                            WHERE b.TicketId = tl.TicketId
                            FOR XML PATH('')
                        ), 1, 2, ''
                    ) AS Products
            ) tl
            CROSS APPLY (
                SELECT 
                    STUFF(
                        (
                            SELECT ', ' + Py.Paymentmode
                            FROM TicketlinePayments pa 
                            INNER JOIN PaymentModes Py ON Py.PaymentmodeId = pa.PaymentModeId
                            WHERE b.TicketId = pa.TicketId
                            FOR XML PATH('')
                        ), 1, 2, ''
                    ) AS PayMode
            ) pa
            CROSS APPLY (
                SELECT 
                    STUFF(
                        (
                            SELECT ', ' + format(CONVERT(NUMERIC(18, 2), tu.Units), '#,##0.00')
                            FROM TicketLines tu
                            WHERE b.TicketId = tu.TicketId
                            FOR XML PATH('')
                        ), 1, 2, ''
                    ) AS Units
            ) tu
            CROSS APPLY (
                SELECT 
                    STUFF(
                        (
                            SELECT ', ' + format(CONVERT(NUMERIC(18, 2), tp.Price), '#,##0.00')
                            FROM TicketLines tp
                            WHERE b.TicketId = tp.TicketId
                            FOR XML PATH('')
                        ), 1, 2, ''
                    ) AS Price
            ) tp
            CROSS APPLY (
                SELECT 
                    STUFF(
                        (
                            SELECT ', ' + format(CONVERT(NUMERIC(18, 2), td.Discount), '#,##0.00')
                            FROM TicketLines td
                            WHERE b.TicketId = td.TicketId
                            FOR XML PATH('')
                        ), 1, 2, ''
                    ) AS Discount
            ) td
            CROSS APPLY (
                SELECT 
                    STUFF(
                        (
                            SELECT ', ' + format(CONVERT(NUMERIC(18, 2), py.TotalUsed), '#,##0.00')
                            FROM TicketlinePayments py
                            WHERE b.TicketId = py.TicketId
                            FOR XML PATH('')
                        ), 1, 2, ''
                    ) AS SaleAmount
            ) py
            WHERE 
                A.TransactionCode NOT LIKE '%-%' AND A.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') 
                AND A.ActualDate >=TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) 
                AND A.ActualDate < TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
                AND (JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 OR D.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer'))
                AND (JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 OR CA.AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement'))
                --AND (@group < 1 OR LG.GroupId = @group)
                AND (JSON_VALUE(@JsonObjectdata, '$.Account') < 1 OR CA.AccountNumber = JSON_VALUE(@JsonObjectdata, '$.Account'))
                AND (JSON_VALUE(@JsonObjectdata, '$.Paymode') < 1 OR H.paymentModeId = JSON_VALUE(@JsonObjectdata, '$.Paymode'))
                AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR L.StationId = JSON_VALUE(@JsonObjectdata, '$.Station'))
                AND (JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 OR B.staffId = JSON_VALUE(@JsonObjectdata, '$.Attendant'))
                AND (JSON_VALUE(@JsonObjectdata, '$.Product') < 1 OR TickL.ProductVariationId = JSON_VALUE(@JsonObjectdata, '$.Product'))
            ORDER BY
                A.ActualDate,
                A.orderKey ASC
            FOR JSON PATH
        ) AS SalesDetails
        FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
    );

END