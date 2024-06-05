CREATE PROCEDURE [dbo].[Usp_ReportShiftSummaryReading] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftSummaryReadingDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON; -- Added semicolon

    SELECT @ShiftSummaryReadingDetailsJson = (
	  SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
           (SELECT * FROM (SELECT STF.Firstname+' '+STF.Lastname AS AttendantName,PC.Categoryname, SPV.Productvariationname AS Descriptions, SUM(SPR.TotalPumpAmount) AS Amount
			FROM  ShiftsPumpReadings SPR
			INNER JOIN Stationshifts SS ON SPR.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
			INNER JOIN  StationTanks SST ON SSP.TankId = SST.TankId
			INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
			INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
			INNER JOIN  Productcategory PC ON SP.CategoryId = PC.CategoryId
			INNER JOIN SystemStaffs STF ON SPR.AttendantId=STF.Userid
			WHERE  STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SPR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SPR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SPR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY SPR.ShiftId, SPV.Productvariationname, PC.Categoryname,STF.Firstname,STF.Lastname
			UNION ALL
			SELECT  STF.Firstname+' '+STF.Lastname AS AttendantName,PC.Categoryname, SPV.Productvariationname AS Descriptions, SUM(LUBE.UnitsTotal) AS Amount
			FROM ShiftLubeandLpg LUBE
			INNER JOIN Stationshifts SS ON LUBE.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid=SPV.ProductvariationId
			INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
			INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
			INNER JOIN SystemStaffs STF ON LUBE.AttendantId=STF.Userid
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR LUBE.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (LUBE.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND LUBE.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY SPV.Productvariationname,PC.Categoryname,LUBE.ShiftId,STF.Firstname,STF.Lastname
			UNION ALL
			SELECT STF.Firstname+' '+STF.Lastname AS AttendantName,'Collections' AS Categoryname, SV.VoucherType AS Descriptions, SUM(SV.VoucherAmount) AS Amount
			FROM ShiftVouchers SV
			INNER JOIN Stationshifts SS ON SV.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemStaffs STF ON SV.AttendantId=STF.Userid
			WHERE SV.VoucherType != 'ShiftExpenses' AND STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SV.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SV.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SV.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY  SV.ShiftId, SV.VoucherType,STF.Firstname,STF.Lastname
			UNION ALL
			SELECT STF.Firstname+' '+STF.Lastname AS AttendantName,'Expenses' AS Categoryname,SV.VoucherType AS Descriptions,SUM(SV.VoucherAmount) AS Amount
			FROM ShiftVouchers SV 
			INNER JOIN Stationshifts SS ON SV.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemStaffs STF ON SV.AttendantId=STF.Userid
			WHERE SV.VoucherType = 'ShiftExpenses' AND STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SV.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SV.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SV.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY SV.ShiftId, SV.VoucherType,STF.Firstname,STF.Lastname
			UNION ALL
			SELECT STF.Firstname+' '+STF.Lastname AS AttendantName,'CreditInvoices' AS Categoryname,'Credit Invoices' AS Descriptions, SUM(ProductTotal) AS Amount
			FROM ShiftCreditInvoices SCI
			INNER JOIN Stationshifts SS ON SCI.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemStaffs STF ON SCI.AttendantId=STF.Userid
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SCI.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SCI.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SCI.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY STF.Firstname,STF.Lastname
			) AS FinancialDetail
			FOR JSON PATH
			) AS FinancialDetails,
			(  
				SELECT SPR.ShiftId,SPV.Productvariationname AS Product,SSP.Pumpname AS PumpName,SST.Name AS TankName,SUM(SPR.OpeningElectronic) AS TotalShillings,SUM(SPR.ClosingElectronic) AS ElectronicAmount,SUM(SPR.TotalPumpAmount) AS ManualAmount
				FROM ShiftsPumpReadings SPR
				INNER JOIN Stationshifts SS ON SPR.ShiftId=SS.ShiftId
			    INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
				INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
				INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
				INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
				WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
                AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SPR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SPR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
                AND SPR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
				GROUP BY SPR.ShiftId, SPV.Productvariationname,SSP.Pumpname,SST.Name
				FOR JSON PATH
			) AS ShiftPumpSaleSummary,
			(   
				SELECT STRR.ShiftId,SPV.Productvariationname AS Product,SST.Name AS TankName,STRR.OpeningQuantity,STRR.ClosingQuantity,STRR.AmountSold
				FROM ShiftsTankReadings STRR
				INNER JOIN Stationshifts SS ON STRR.ShiftId=SS.ShiftId
			    INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
				INNER JOIN StationTanks SST ON STRR.TankId = SST.TankId
				INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
				WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
                AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR STRR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (STRR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
                AND STRR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
				GROUP BY STRR.ShiftId, SPV.Productvariationname,SST.Name,STRR.OpeningQuantity,STRR.ClosingQuantity,STRR.AmountSold
				FOR JSON PATH
			) AS ShiftTankSaleSummary,
			(
				SELECT LUBE.ShiftId,SPV.Productvariationname AS Product,PC.Categoryname AS Category, SUM(LUBE.UnitsTotal) AS DryTotalAmount
				FROM ShiftLubeandLpg LUBE
				INNER JOIN Stationshifts SS ON LUBE.ShiftId=SS.ShiftId
			    INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
				INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid = SPV.ProductvariationId
				INNER JOIN SystemProduct SP ON SPV.ProductId=SP.ProductId
				INNER JOIN Productcategory PC ON SP.CategoryId=PC.CategoryId
				WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
                AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR LUBE.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (LUBE.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
                AND LUBE.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
				GROUP BY LUBE.ShiftId, SPV.Productvariationname,PC.Categoryname
				FOR JSON PATH
			) AS LpgandLubeSummary,
			(SELECT AttendantName,SUM(Amount) AS Amount
			FROM (
			SELECT 'Sales' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,SUM(SPR.TotalPumpAmount) AS Amount
			FROM ShiftsPumpReadings SPR
			INNER JOIN Stationshifts SSS ON SPR.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			INNER JOIN SystemStaffs SS ON SPR.AttendantId= SS.UserId 
			INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
			INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
			INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
			INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
			INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SPR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SPR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SPR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY SS.FirstName,SS.LastName 
			UNION ALL
			SELECT 'Lube' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,SUM(LUBE.UnitsTotal) AS Amount
			FROM ShiftLubeandLpg LUBE
			INNER JOIN Stationshifts SSS ON LUBE.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			INNER JOIN SystemStaffs SS ON LUBE.AttendantId= SS.UserId 
			INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid = SPV.ProductvariationId
			INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
			INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR LUBE.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (LUBE.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND LUBE.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY  SS.FirstName,SS.LastName 
			UNION ALL
			SELECT 'Voucher' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,-SUM(SV.VoucherAmount) AS Amount
			FROM ShiftVouchers SV
			INNER JOIN Stationshifts SSS ON SV.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			INNER JOIN SystemStaffs SS ON SV.AttendantId= SS.UserId 
			WHERE SV.VoucherType != 'ShiftExpenses' AND STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SV.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SV.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SV.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY  SS.FirstName,SS.LastName 
			UNION ALL
			SELECT 'Expenses' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,-SUM(SV.VoucherAmount) AS Amount
			FROM ShiftVouchers SV
			INNER JOIN Stationshifts SSS ON SV.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			INNER JOIN SystemStaffs SS ON SV.AttendantId= SS.UserId 
			WHERE SV.VoucherType = 'ShiftExpenses' AND STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SV.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SV.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SV.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY  SS.FirstName,SS.LastName 
			UNION ALL
			SELECT 'CreditInvoice' AS Category, SS.FirstName+' '+SS.LastName AS AttendantName,-SUM(ProductTotal) AS Amount
			FROM ShiftCreditInvoices SCI
			INNER JOIN Stationshifts SSS ON SCI.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			INNER JOIN SystemStaffs SS ON SCI.AttendantId= SS.UserId 
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SCI.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SCI.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SCI.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			GROUP BY  SS.FirstName,SS.LastName 
			) AS CashToPay
			GROUP BY AttendantName
			FOR JSON PATH) AS AttendantShiftSummary,
			(SELECT SUM(Amount) AS ExpectedCash FROM (
			SELECT SUM(SPR.TotalPumpAmount) AS Amount
			FROM ShiftsPumpReadings SPR
			INNER JOIN Stationshifts SS ON SPR.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
			INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
			INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
			INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
			INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SPR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SPR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SPR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			UNION ALL
			SELECT SUM(LUBE.UnitsTotal) AS Amount
			FROM ShiftLubeandLpg LUBE
			INNER JOIN Stationshifts SS ON LUBE.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid = SPV.ProductvariationId
			INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
			INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR LUBE.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (LUBE.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND LUBE.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			UNION ALL
			SELECT -SUM(SV.VoucherAmount) AS Amount
			FROM ShiftVouchers SV 
			INNER JOIN Stationshifts SSS ON SV.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			WHERE SV.VoucherType != 'ShiftExpenses' AND STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SV.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SV.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SV.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			UNION ALL
			SELECT -SUM(SV.VoucherAmount) AS Amount
			FROM ShiftVouchers SV 
			INNER JOIN Stationshifts SSS ON SV.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			WHERE SV.VoucherType = 'ShiftExpenses' AND STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SV.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SV.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SV.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			UNION ALL
			SELECT -SUM(ProductTotal) AS Amount
			FROM ShiftCreditInvoices SCI
			INNER JOIN Stationshifts SSS ON SCI.ShiftId=SSS.ShiftId
			INNER JOIN SystemStations STS ON SSS.StationId=STS.StationId
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SCI.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SCI.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SCI.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			) AS CashToPay
			) AS ExpectedCash
	FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER
    );
END