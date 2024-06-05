CREATE PROCEDURE [dbo].[USP_SalesTransactions]
    @StartDate VARCHAR(100),
    @EndDate VARCHAR(100),
    @customer BIGINT,
    @agreement BIGINT,
    @group BIGINT,
    @transactiontypeId BIGINT,
    @station BIGINT,
    @paymode BIGINT,
    @account BIGINT,
    @attendant BIGINT,
    @product BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    WITH FinanceTransactions AS
    (
        SELECT
            FinancetransactionId, transactioncode, Saledescription, ActualDate, DateCreated, SaleRefence, ParentId, Saletransactiontype, AutomationRefence,
            10 * FinancetransactionId AS orderKey
        FROM VWFinanceTransactions
        WHERE ParentId = 0

        UNION ALL

        SELECT
            FinancetransactionId, transactioncode, Saledescription, ActualDate, DateCreated, SaleRefence, ParentId, Saletransactiontype, AutomationRefence,
            10 * ParentId + 1 AS orderKey
        FROM VWFinanceTransactions
        WHERE ParentId != 0
    )

    SELECT
        A.ActualDate AS TransactionDate,
        A.DateCreated AS PostingDate,
        A.TransactionCode,
        A.AutomationRefence,
        A.parentid,
        A.orderKey,
        L.Sname AS Station,
        ISNULL(C.Fullname, '') AS Attendant,
        CASE WHEN D.Designation = 'Individual' THEN ISNULL(D.FirstName, '') + ' ' + ISNULL(D.LastName, '') ELSE D.CompanyName END AS Customer,
        '' AS Groupname,
        CA.AccountNumber,
        COALESCE(SC.CardSNO, 'Not Set') AS Mask,
        COALESCE(k.EquipmentRegNo,'N/A') AS Equipment,
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
    LEFT JOIN SystemStaffs C ON B.StaffId = C.StaffId
    LEFT JOIN SystemStations L ON B.stationId = L.Tenantstationid
    LEFT JOIN CustomerAccount CA ON B.AccountId = CA.AccountId
    --INNER JOIN FmsLnkAccountGroups LG ON CA.Id = LG.AccountId
    --INNER JOIN FmsAgreementGroups AG ON LG.GroupId = AG.Id
    LEFT JOIN CustomerAgreements AG ON AG.AgreementId = CA.AgreementId
	LEFT JOIN Customers D ON AG.CustomerId = D.CustomerId
	LEFT JOIN SystemAccountCards SAC ON CA.AccountId=SAC.AccountId
	LEFT JOIN Systemcard SC ON SAC.CardId=SC.CardId
    CROSS APPLY
    (
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
    CROSS APPLY
    (
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
    CROSS APPLY
    (
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
    CROSS APPLY
    (
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
    CROSS APPLY
    (
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
    CROSS APPLY
    (
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
        A.TransactionCode NOT LIKE '%-%'
        AND A.ActualDate >= CONVERT(DATETIME, @StartDate)
        AND A.ActualDate < CONVERT(DATETIME, @EndDate)
        AND (@customer < 1 OR D.CustomerId = @customer)
        AND (@agreement < 1 OR CA.AgreementId = @agreement)
        --AND (@group < 1 OR LG.GroupId = @group)
        AND (@account < 1 OR CA.AccountNumber = @account)
        AND (@paymode < 1 OR H.paymentModeId = @paymode)
        AND (@station < 1 OR L.Tenantstationid = @station)
        AND (@transactiontypeId < 1 OR A.Saletransactiontype = @transactiontypeId)
        AND (@attendant < 1 OR B.staffId = @attendant)
        AND (@product < 1 OR TickL.ProductVariationId = @product)
    ORDER BY
        A.ActualDate,
        A.orderKey ASC;
END