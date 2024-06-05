CREATE PROCEDURE [dbo].[Usp_ReportCustomerPaymentData] 
@JsonObjectdata VARCHAR(MAX) OUTPUT,
@CustomerPaymentDataDetailsJson VARCHAR(MAX) OUTPUT
as 
begin
SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END
	    SELECT
        @CustomerPaymentDataDetailsJson = (
        SELECT 
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 THEN 'ALL' ELSE (SELECT RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) FROM Customers C WHERE C.CustomerId=JSON_VALUE(@JsonObjectdata, '$.Customer')) END)AS CustomerName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 THEN 'ALL' ELSE (SELECT  TA.Agreementtypename FROM CustomerAgreements CA INNER JOIN AgreementTypes TA ON CA.AgreemettypeId=TA.AgreemettypeId INNER JOIN CustomerAccount AC ON AC.AgreementId=CA.AgreementId WHERE CA.AgreementId=JSON_VALUE(@JsonObjectdata, '$.Agreement') AND AC.ParentId=0) END)AS AgreementName,
	     	(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Paymode') < 1 THEN 'ALL' ELSE (SELECT PM.Paymentmode FROM Paymentmodes PM WHERE PM.PaymentmodeId=JSON_VALUE(@JsonObjectdata, '$.Paymode')) END)AS PaymentModeName,
           (
			select A.TransactionDate, A.DateCreated as PostingDate,b.Saledescription as Description, b.TransactionCode as Reference, A.TransactionReference as TopupReference, 
			RTRIM(LTRIM(ISNULL(D.FirstName, '') + ' ' + ISNULL(D.LastName, '') + ISNULL(D.CompanyName, ''))) AS Customer,
			(select top 1 AccountNumber from CustomerAccount where ParentId=0 AND AgreementId = C.AgreementId) as Account, '' as Mask,
			E.Paymentmode as TopupMode,  F.Firstname+' '+F.Lastname as Attendant, A.Amount     
			FROM CustomerPayments A
			INNER JOIN FinanceTransactions B on B.FinanceTransactionId = A.FInanceTransactionId
			INNER JOIN CustomerAgreements C on C.AgreementId = A.AgreementId
			INNER JOIN Customers D on D.CustomerId = C.CustomerId
			INNER JOIN PaymentModes E on E.PaymentmodeId = A.PaymentModeId
			INNER JOIN SystemStaffs F ON A.CreatedBy=F.Userid
			where B.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND A.TransactionDate >= TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) and A.TransactionDate <= dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))) 
			and  (JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 OR D.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer'))
			and  (JSON_VALUE(@JsonObjectdata, '$.Agreement') < 1 OR C.AgreementId = JSON_VALUE(@JsonObjectdata, '$.Agreement')) 
			and (JSON_VALUE(@JsonObjectdata, '$.Paymode')<1 OR E.PaymentmodeId = JSON_VALUE(@JsonObjectdata, '$.Paymode'))
			order by A.TransactionDate desc
			   FOR JSON PATH
        ) AS CustomerPaymentData
        FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
    );
end
