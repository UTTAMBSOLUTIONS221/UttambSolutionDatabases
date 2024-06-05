CREATE PROCEDURE [dbo].[Usp_ReportShiftCustomerStatementReading] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftCustomerStatementDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
	WITH CombinedData AS (
    SELECT SCI.Datecreated,CASE WHEN CS.Designation='Corporate' THEN CS.Companyname ELSE CS.Firstname+' '+ CS.Lastname END AS Customername,'Debit' AS DebitCredit,
        ISNULL(CE.EquipmentRegNo,'N/A') AS Equipment,SS.Firstname+' '+SS.Lastname AS Attendant,SPV.Productvariationname AS Productname,SCI.ProductUnits,
        SCI.ProductPrice,'N/A' AS Paymentmode,'N/A' AS PaymentReference,SCI.ProductTotal,-1*(SCI.ProductTotal) AS Amount
    FROM ShiftCreditInvoices SCI
    INNER JOIN SystemProductvariation SPV ON SCI.ProductVariationId = SPV.ProductvariationId
    LEFT JOIN CustomerEquipments CE ON SCI.EquipmentId = CE.EquipmentId
    INNER JOIN SystemStaffs SS ON SCI.AttendantId = SS.Userid
    INNER JOIN Customers CS ON SCI.CustomerId = CS.CustomerId
	INNER JOIN Stationshifts SST ON SCI.ShiftId=SST.ShiftId
	INNER JOIN SystemStations STS ON SST.StationId=STS.StationId
	WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND SCI.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AND SCI.CustomerId =JSON_VALUE(@JsonObjectdata, '$.Customer') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR SST.StationId = JSON_VALUE(@JsonObjectdata, '$.Station'))
    UNION 
    SELECT SP.Datecreated,CASE WHEN CS.Designation='Corporate' THEN CS.Companyname ELSE CS.Firstname+' '+ CS.Lastname END AS Customername,'Credit' AS DebitCredit,
        '' AS Equipment,SS.Firstname+' '+SS.Lastname AS Attendant,'N/A' AS Productname,0 AS ProductUnits,
        0 AS ProductPrice,PM.Paymentmode,SP.PaymentReference,SP.PaymentAmount AS ProductTotal,SP.PaymentAmount AS Amount  
    FROM ShiftPayment SP
    INNER JOIN Customers CS ON SP.CustomerId = CS.CustomerId
    INNER JOIN SystemStaffs SS ON SP.AttendantId = SS.Userid
    INNER JOIN Paymentmodes PM ON SP.PaymentModeId = PM.PaymentmodeId
	INNER JOIN Stationshifts SST ON SP.ShiftId=SST.ShiftId
	INNER JOIN SystemStations STS ON SST.StationId=STS.StationId
	WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND SP.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AND SP.CustomerId =JSON_VALUE(@JsonObjectdata, '$.Customer') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR SST.StationId = JSON_VALUE(@JsonObjectdata, '$.Station'))
	)
    SELECT @ShiftCustomerStatementDetailsJson = 
			(SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 THEN 'ALL' ELSE (SELECT CASE WHEN CS.Designation='Corporate' THEN CS.Companyname ELSE CS.Firstname+' '+ CS.Lastname END AS Customer FROM Customers CS WHERE CS.CustomerId=JSON_VALUE(@JsonObjectdata, '$.Customer')) END) AS CustomerName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
            (SELECT Datecreated,Customername,Equipment,Attendant,Productname,ProductUnits,ProductPrice,Paymentmode,PaymentReference,DebitCredit,ProductTotal,Amount,SUM(Amount) OVER (ORDER BY Datecreated) AS RunningBalance 
			 FROM CombinedData
			 FOR JSON PATH
			) AS ShiftCustomerStatement
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );
END