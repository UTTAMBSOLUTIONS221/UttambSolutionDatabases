CREATE PROCEDURE [dbo].[Usp_Getsystemstationshiftdatabyshiftid]
@TenantStationId BIGINT,
@StationShiftId BIGINT,
@StationShiftDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		IF(@StationShiftId=0)
		BEGIN
			IF EXISTS(SELECT ShiftId FROM Stationshifts WHERE ShiftStatus=0)
			BEGIN
			 Select  1 as RespStatus, 'There is and open Shift which needs to be closed!' as RespMessage;
			 Return;
			END
		END
		BEGIN TRANSACTION;
		IF(@StationShiftId>0)
		BEGIN
			SET @StationShiftDetails=(SELECT 1 AS HasPrevious , b.ShiftId as ShiftId, b.ShiftCode AS ShiftCode,b.ShiftDateTime,a.StationId, a.Sname AS LocationData,b.CashOrAccount AS CashorAccount,
			ShiftBankedAmount,ShiftBalance,ShiftBankReference,ShiftReference,b.ShiftCategory,b.ShiftStatus,
			  (SELECT SUM(STRR.AmountSold) 
					FROM ShiftsTankReadings STRR
					INNER JOIN StationTanks SST ON STRR.TankId = SST.TankId
					INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
					WHERE STRR.ShiftId=b.ShiftId 
			   )AS ExpectedTankAmount,
			   (SELECT SUM(SPR.TotalShilling)
				FROM ShiftsPumpReadings SPR
				INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
				INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
				INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
				WHERE SPR.ShiftId=b.ShiftId 
			   )AS ExpectedPumpAmount,
			   (( SELECT SUM(SPR.TotalShilling)
				FROM ShiftsPumpReadings SPR
				INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
				INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
				INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
				WHERE SPR.ShiftId=b.ShiftId 
			   )-(SELECT SUM(STRR.AmountSold) 
					FROM ShiftsTankReadings STRR
					INNER JOIN StationTanks SST ON STRR.TankId = SST.TankId
					INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
					WHERE STRR.ShiftId=b.ShiftId 
			   )
			   ) AS GainLoss,
			   (
				(
					ISNULL((
							SELECT SUM(SPR.TotalShilling)
							FROM ShiftsPumpReadings SPR
							INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
							INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
							INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
							WHERE SPR.ShiftId = b.ShiftId
						), 0)
					- ISNULL((
							SELECT SUM(STRR.AmountSold)
							FROM ShiftsTankReadings STRR
							INNER JOIN StationTanks SST ON STRR.TankId = SST.TankId
							INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
							WHERE STRR.ShiftId = b.ShiftId
						), 0)
				) / 
				CASE 
					WHEN ISNULL((
							SELECT SUM(SPR.TotalShilling)
							FROM ShiftsPumpReadings SPR
							INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
							INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
							INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
							WHERE SPR.ShiftId = b.ShiftId
						), 0) = 0 THEN 1
					ELSE 
						ISNULL((
							SELECT SUM(SPR.TotalShilling)
							FROM ShiftsPumpReadings SPR
							INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
							INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
							INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
							WHERE SPR.ShiftId = b.ShiftId
						), 0)
				END
			) * 100 AS PercentGainLoss,
				(
				    SELECT  SD.ShiftPumpReadingId,SD.ShiftId,PN.Pumpid AS PumpId,PN.Nozzleid AS NozzleId,SP.Pumpname AS Pumpname,SP.Pumpname+'-'+PN.Nozzle AS Warehouse,ST.ProductVariationId AS ProductVariationId,SPV.Productvariationname,SD.ProductPrice,SD.AttendantId,SD.OpeningShilling,
				    SD.ClosingShilling,SD.TotalShilling,SD.ShillingDifference,SD.OpeningElectronic,SD.ClosingElectronic,SD.ElectronicSold,SD.ElectronicAmount,SD.OpeningManual,SD.ClosingManual,SD.ManualSold,SD.ManualAMount,SD.LitersDifference,SD.PumpRttAmount,SD.TotalPumpAmount,SD.Extra,SD.Extra1,SD.Extra2,SD.Extra3,
				    SD.Extra4,SD.Extra5,SD.Extra6,SD.Extra7,SD.Extra8,SD.Extra9,SD.Extra10,SD.Createdby,SD.Modifiedby,SD.Datemodified,SD.Datecreated
				  	FROM ShiftsPumpReadings SD
					INNER JOIN PumpNozzles PN ON SD.NozzleId=PN.NozzleId
					INNER JOIN Stationpumps SP ON PN.Pumpid=SP.Pumpid
					INNER JOIN Stationtanks ST ON SP.Tankid=ST.Tankid
					INNER JOIN SystemProductvariation SPV ON ST.ProductvariationId=SPV.ProductvariationId
					LEFT JOIN SystemStaffs SS ON SD.AttendantId=SS.UserId
					WHERE  SP.StationId=a.StationId AND SD.ShiftId=b.ShiftId
				   FOR JSON PATH
				) AS ShiftPumpReading,
				(
				  SELECT SSTR.ShiftTankReadingId,SSTR.ShiftId,SSD.TankId AS TankId,SSD.Name AS Tankname,SSTR.AttendantId,SSTR.ProductPrice,SSTR.OpeningQuantity,SSTR.ClosingQuantity,SSTR.QuantitySold,SSTR.AmountSold,SSTR.Extra,SSTR.Extra1,
				  SSTR.Extra2,SSTR.Extra3,SSTR.Extra4,SSTR.Extra5,SSTR.Extra6,SSTR.Extra7,SSTR.Extra8,SSTR.Extra9,SSTR.Extra10,SSD.Createdby,SSD.Modifiedby,SSTR.Datemodified,SSTR.Datecreated
  	             FROM ShiftsTankReadings SSTR 
				 INNER JOIN Stationtanks SSD  ON SSD.TankId=SSTR.TankId
				 INNER JOIN SystemProductvariation SPV ON SSD.ProductvariationId=SPV.ProductvariationId
				  WHERE SSD.StationId=a.StationId AND SSTR.ShiftId=b.ShiftId
				  FOR JSON PATH
				) AS ShiftTankReading,
				(
				 SELECT SLL.ShiftLubeLpgId,SLL.ShiftId,SLL.StockTypeId,SLL.AttendantId,SLL.ProductVariationId,SPV.Productvariationname,PC.Categoryname,SLL.OpeningUnits,SLL.ClosingUnits,SLL.UnitsSold,PLP.ProductPrice,SLL.UnitsTotal,SLL.Extra,
				  SLL.Extra1,SLL.Extra2,SLL.Extra3,SLL.Extra4,SLL.Extra5,SLL.Extra6,SLL.Extra7,SLL.Extra8,SLL.Extra9,SLL.Extra10,SLL.Createdby,SLL.Modifiedby,SLL.Datemodified,SLL.Datecreated
				  FROM SystemProductvariation SPV
				  INNER JOIN SystemProduct SP ON SPV.ProductId=SP.ProductId
				  INNER JOIN Productcategory PC  ON SP.CategoryId=PC.CategoryId
				  INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
				  INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
				  LEFT JOIN ShiftLubeandLpg SLL ON  SPV.ProductvariationId=SLL.ProductvariationId 
				  WHERE  PL.IsDefault=1 AND PLP.StationId=a.StationId AND SLL.ShiftId=b.ShiftId 
				  FOR JSON PATH
				) AS ShiftLubeReading,
				(SELECT SDT.PurchaseId,SDT.ShiftId,SDT.InvoiceNumber,SDT.SupplierId,SSP.SupplierName,SDT.InvoiceAmount,SDT.TransportAmount,SDT.InvoiceDate,SDT.TruckNumber,SDT.DriverName,SDT.Extra,SDT.Extra1,SDT.Extra2,SDT.Extra3,SDT.Extra4 ,SDT.Extra5,SDT.Extra6,SDT.Extra7,SDT.Extra8,SDT.Extra9,SDT.Extra10,SDT.Createdby,SDT.Modifiedby,SDT.Datemodified,SDT.Datecreated
				  FROM ShiftPurchases SDT
				  INNER JOIN StationShifts SSH ON SDT.ShiftId=SSH.ShiftId
				  INNER JOIN SystemSuppliers SSP ON SDT.SupplierId=SSP.SupplierId
				  WHERE SDT.WetDryPurchase  ='WetStockPurchase' AND  SSH.StationId=a.StationId AND SDT.ShiftId=b.ShiftId 
				  FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
				) AS WetstockPurchases,
				 (SELECT SDT.PurchaseId,SDT.ShiftId,SDT.InvoiceNumber,SDT.SupplierId,SSP.SupplierName,SDT.InvoiceAmount,SDT.TransportAmount,SDT.InvoiceDate,SDT.TruckNumber,SDT.DriverName,SDT.Extra,SDT.Extra1,SDT.Extra2,SDT.Extra3,SDT.Extra4 ,SDT.Extra5,SDT.Extra6,SDT.Extra7,SDT.Extra8,SDT.Extra9,SDT.Extra10,SDT.Createdby,SDT.Modifiedby,SDT.Datemodified,SDT.Datecreated
				  FROM ShiftPurchases SDT
				  INNER JOIN StationShifts SSH ON SDT.ShiftId=SSH.ShiftId
				  INNER JOIN SystemSuppliers SSP ON SDT.SupplierId=SSP.SupplierId
				  WHERE SDT.WetDryPurchase ='DryStockPurchase' AND  SSH.StationId=a.StationId AND SDT.ShiftId=b.ShiftId 
			      FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
				) AS DrystockPurchases,
				(   
				    SELECT SPR.ShiftId,SPV.Productvariationname AS Product,SSP.Pumpname AS PumpName,SST.Name AS TankName,SUM(SPR.ElectronicSold) AS PumpLitres,SUM(SPR.TotalShilling) AS TotalShillings,SUM(SPR.ClosingElectronic) AS ElectronicAmount,SUM(SPR.TotalPumpAmount) AS ManualAmount
					FROM ShiftsPumpReadings SPR
					INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
					INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
					INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
					WHERE SPR.ShiftId=b.ShiftId 
					GROUP BY SPR.ShiftId, SPV.Productvariationname,SSP.Pumpname,SST.Name
					FOR JSON PATH
				) AS ShiftPumpSaleSummary,
				(   
				    SELECT STRR.ShiftId,SPV.Productvariationname AS Product,SST.Name AS TankName,STRR.OpeningQuantity,STRR.ClosingQuantity,STRR.QuantitySold,STRR.AmountSold
					FROM ShiftsTankReadings STRR
					INNER JOIN StationTanks SST ON STRR.TankId = SST.TankId
					INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
					WHERE STRR.ShiftId=b.ShiftId 
					GROUP BY STRR.ShiftId, SPV.Productvariationname,SST.Name,STRR.OpeningQuantity,STRR.ClosingQuantity,STRR.AmountSold,STRR.QuantitySold
					FOR JSON PATH
				) AS ShiftTankSaleSummary,
				(
					SELECT LUBE.ShiftId,SPV.Productvariationname AS Product,PC.Categoryname AS Category, SUM(LUBE.UnitsTotal) AS DryTotalAmount
					FROM ShiftLubeandLpg LUBE
					INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid = SPV.ProductvariationId
					INNER JOIN SystemProduct SP ON SPV.ProductId=SP.ProductId
					INNER JOIN Productcategory PC ON SP.CategoryId=PC.CategoryId
					WHERE LUBE.ShiftId = b.ShiftId 
					GROUP BY LUBE.ShiftId, SPV.Productvariationname,PC.Categoryname
					FOR JSON PATH
				) AS LpgandLubeSummary,
			    (
					SELECT * FROM (SELECT PC.Categoryname, SPV.Productvariationname AS Descriptions, SUM(SPR.TotalPumpAmount) AS Amount
					FROM   ShiftsPumpReadings SPR
					INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
					INNER JOIN  StationTanks SST ON SSP.TankId = SST.TankId
					INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
					INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
					INNER JOIN  Productcategory PC ON SP.CategoryId = PC.CategoryId
				    WHERE SPR.ShiftId = b.ShiftId 
					GROUP BY SPR.ShiftId, SPV.Productvariationname, PC.Categoryname
					UNION ALL
					SELECT PC.Categoryname, SPV.Productvariationname AS Descriptions, SUM(LUBE.UnitsTotal) AS Amount
					FROM ShiftLubeandLpg LUBE
					INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid=SPV.ProductvariationId
					INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
					INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
					GROUP BY SPV.Productvariationname,PC.Categoryname,LUBE.ShiftId
					UNION ALL
					SELECT 'Collections' AS Categoryname, SV.VoucherType AS Descriptions, SUM(SV.VoucherAmount) AS Amount
					FROM ShiftVouchers SV  
					WHERE SV.VoucherType != 'ShiftExpenses' AND  SV.ShiftId = b.ShiftId 
					GROUP BY  SV.ShiftId, SV.VoucherType
					UNION ALL
					SELECT 'CreditInvoices' AS Categoryname,'Credit Invoices' AS Descriptions, SUM(ProductTotal) AS Amount
					FROM ShiftCreditInvoices
					WHERE ShiftId = b.ShiftId 
					UNION ALL
					SELECT 'ShiftTopup' AS Categoryname,'Shift ShiftTopup' AS Descriptions, SUM(SHT.TopupAmount) AS Amount
					FROM ShiftTopup SHT
					WHERE SHT.ShiftId = b.ShiftId 
					UNION ALL
					SELECT 'Expenses' AS Categoryname,SV.VoucherType AS Descriptions,SUM(SV.VoucherAmount) AS Amount
					FROM ShiftVouchers SV 
					WHERE SV.VoucherType = 'ShiftExpenses' AND  SV.ShiftId = b.ShiftId 
					GROUP BY SV.ShiftId, SV.VoucherType
					) AS FinancialDetail
					FOR JSON PATH
				) AS FinancialDetails, 
				(
					SELECT SUM(Amount) AS ShiftTotalAmount
					FROM (
						SELECT SUM(SPR.TotalPumpAmount) AS Amount
						FROM ShiftsPumpReadings SPR
						INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
						INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
						INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
						INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
						INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
						WHERE SPR.ShiftId = b.ShiftId  
						UNION ALL
						SELECT SUM(LUBE.UnitsTotal) AS Amount
						FROM ShiftLubeandLpg LUBE
						INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid = SPV.ProductvariationId
						INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
						INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
						WHERE LUBE.ShiftId = b.ShiftId 
						UNION ALL
						SELECT -SUM(SV.VoucherAmount) AS Amount
						FROM ShiftVouchers SV 
						WHERE SV.VoucherType != 'ShiftExpenses' AND SV.ShiftId =b.ShiftId   
						UNION ALL
						SELECT -SUM(SV.VoucherAmount) AS Amount
						FROM ShiftVouchers SV 
						WHERE SV.VoucherType = 'ShiftExpenses' AND SV.ShiftId =b.ShiftId  
						UNION ALL
						SELECT -SUM(STP.TopupAmount) AS Amount
						FROM ShiftTopup STP 
						WHERE STP.ShiftId =b.ShiftId  
						UNION ALL
						SELECT -SUM(ProductTotal) AS Amount
						FROM ShiftCreditInvoices
						WHERE ShiftId = b.ShiftId 
					) AS CashToPay
				) AS ShiftTotalAmount,
				(  
					    SELECT AttendantName,SUM(Amount) AS Amount
					    FROM (
						SELECT 'Sales' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,SUM(SPR.TotalPumpAmount) AS Amount
						FROM ShiftsPumpReadings SPR
						INNER JOIN SystemStaffs SS ON SPR.AttendantId= SS.UserId 
						INNER JOIN StationPumps SSP ON SPR.PumpId = SSP.Pumpid
						INNER JOIN StationTanks SST ON SSP.TankId = SST.TankId
						INNER JOIN SystemProductvariation SPV ON SST.Productvariationid = SPV.ProductvariationId
						INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
						INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
						WHERE SPR.ShiftId =  b.ShiftId
						GROUP BY SS.FirstName,SS.LastName 
						UNION ALL
						SELECT 'Lube' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,SUM(LUBE.UnitsTotal) AS Amount
						FROM ShiftLubeandLpg LUBE
						INNER JOIN SystemStaffs SS ON LUBE.AttendantId= SS.UserId 
						INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid = SPV.ProductvariationId
						INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
						INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
						WHERE LUBE.ShiftId =  b.ShiftId
						GROUP BY  SS.FirstName,SS.LastName 
						UNION ALL
						SELECT 'Voucher' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,-SUM(SV.VoucherAmount) AS Amount
						FROM ShiftVouchers SV
					    INNER JOIN SystemStaffs SS ON SV.AttendantId= SS.UserId 
						WHERE SV.VoucherType != 'ShiftExpenses' AND SV.ShiftId =  b.ShiftId
						GROUP BY  SS.FirstName,SS.LastName 
						UNION ALL
						SELECT 'Expenses' AS Category,SS.FirstName+' '+SS.LastName AS AttendantName,-SUM(SV.VoucherAmount) AS Amount
						FROM ShiftVouchers SV
						INNER JOIN SystemStaffs SS ON SV.AttendantId= SS.UserId 
						WHERE SV.VoucherType = 'ShiftExpenses' AND SV.ShiftId =  b.ShiftId
						GROUP BY  SS.FirstName,SS.LastName 
					    UNION ALL
						SELECT 'CreditInvoice' AS Category, SS.FirstName+' '+SS.LastName AS AttendantName,-SUM(ProductTotal) AS Amount
						FROM ShiftCreditInvoices SCI
					    INNER JOIN SystemStaffs SS ON SCI.AttendantId= SS.UserId 
						WHERE ShiftId = b.ShiftId
						GROUP BY  SS.FirstName,SS.LastName 
						UNION ALL
						SELECT 'ShiftTopup' AS Category, SS.FirstName+' '+SS.LastName AS AttendantName,-SUM(SHT.TopupAmount) AS Amount
						FROM ShiftTopup SHT
					    INNER JOIN SystemStaffs SS ON SHT.AttendantId= SS.UserId 
						WHERE ShiftId = b.ShiftId
						GROUP BY  SS.FirstName,SS.LastName 
					 ) AS CashToPay
				GROUP BY AttendantName
				FOR JSON PATH) AS AttendantShiftSummary
				FROM SystemStations a
				INNER JOIN Stationshifts b ON a.StationId=b.StationId
				WHERE a.StationId=@TenantStationId AND b.ShiftId=@StationShiftId
				FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
			)
		END
		ELSE
		BEGIN
		IF((SELECT COUNT(SS.ShiftId) FROM Stationshifts SS WHERE SS.StationId=@TenantStationId)>0)
		BEGIN 
		SET @StationShiftDetails =(SELECT 1 AS HasPrevious ,0 as ShiftId, CONCAT('SHIFT',  a.TenantId, FORMAT(GETDATE(), 'yyyyMMdd')) AS ShiftCode,GETDATE() AS ShiftDateTime,a.StationId, a.Sname AS LocationData,'' AS CashorAccount,0 AS ShiftBalance,'' AS ShiftCategory,'' AS ShiftBankReference,'' AS ShiftReference,0 AS Createdby,0 AS Modifiedby,
				(
				    SELECT 0 AS ShiftPumpReadingId,0 AS ShiftId,PN.Pumpid AS PumpId,PN.Nozzleid AS NozzleId,SP.Pumpname AS Pumpname,SP.Pumpname + '-' + PN.Nozzle AS Warehouse,ST.ProductVariationId AS ProductVariationId,SPV.Productvariationname,PLP.ProductPrice,0 AS AttendantId,
					COALESCE(LastEntry.ClosingShilling, 0) AS OpeningShilling,0 AS ClosingShilling,0 AS TotalShilling,0 AS ShillingDifference,COALESCE(LastEntry.ClosingElectronic, 0) AS OpeningElectronic,0 AS ClosingElectronic,0 AS ElectronicSold,0 AS ElectronicAmount,COALESCE(LastEntry.ClosingManual, 0) AS OpeningManual,0 AS ClosingManual,0 AS ManualSold,0 AS ManualDifference,0 AS LitersDifference,0 AS PumpRttAmount,0 AS TotalPumpAmount,SD.Createdby,SD.Modifiedby,SD.Datemodified,SD.Datecreated
				    FROM PumpNozzles PN 
					LEFT JOIN ShiftsPumpReadings SD ON PN.NozzleId=SD.NozzleId 
					INNER JOIN Stationpumps SP ON PN.Pumpid = SP.Pumpid
					INNER JOIN Stationtanks ST ON SP.Tankid = ST.Tankid
					INNER JOIN SystemProductvariation SPV ON ST.ProductvariationId = SPV.ProductvariationId
					INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
					INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
					LEFT JOIN (SELECT NozzleId,MAX(CASE WHEN ClosingShilling IS NOT NULL THEN ClosingShilling ELSE 0 END) AS ClosingShilling,MAX(CASE WHEN ClosingElectronic IS NOT NULL THEN ClosingElectronic ELSE 0 END) AS ClosingElectronic,MAX(CASE WHEN ClosingManual IS NOT NULL THEN ClosingManual ELSE 0 END) AS ClosingManual FROM ShiftsPumpReadings GROUP BY NozzleId) AS LastEntry ON SD.NozzleId = LastEntry.NozzleId 
					WHERE PL.IsDefault = 1  AND PLP.StationId=a.StationId
				   FOR JSON PATH
				) AS ShiftPumpReading,
				(
					SELECT 0 AS ShiftTankReadingId,0 AS ShiftId,SSD.TankId AS TankId,SSD.Name AS Tankname,0 AS AttendantId,PLP.ProductPrice,COALESCE(LastClosing.ClosingQuantity, 0) AS OpeningQuantity,0 AS ClosingQuantity,0 AS QuantitySold,0 AS AmountSold,SSD.Createdby,SSD.Modifiedby,SSTR.Datemodified,SSTR.Datecreated
					FROM Stationtanks SSD
					LEFT JOIN ShiftsTankReadings SSTR  ON SSD.TankId = SSTR.TankId
					INNER JOIN SystemProductvariation SPV ON SSD.ProductvariationId = SPV.ProductvariationId
					INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
					INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
					LEFT JOIN (SELECT TankId, MAX(ClosingQuantity) AS ClosingQuantity FROM ShiftsTankReadings GROUP BY TankId) AS LastClosing ON SSD.TankId = LastClosing.TankId
					WHERE PL.IsDefault = 1 AND PLP.StationId=a.StationId
					FOR JSON PATH
				) AS ShiftTankReading,
				(
				    SELECT 0 AS ShiftLubeLpgId,0 AS ShiftId,0 AS StockTypeId,0 AS AttendantId,SPV.ProductVariationId AS ProductVariationId,SPV.Productvariationname,PC.Categoryname,COALESCE(LastClosing.ClosingUnits, 0) AS OpeningUnits,0 AS ClosingUnits,0 AS UnitsSold,PLP.ProductPrice,0 AS UnitsTotal,0 AS Createdby,0 AS Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
					FROM SystemProductvariation SPV
					LEFT JOIN ShiftLubeandLpg SLP ON SLP.ProductVariationId=SPV.ProductvariationId
					INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
					INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
					INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId = PLP.ProductvariationId
					INNER JOIN PriceList PL ON PLP.PriceListId = PL.PriceListId
					LEFT JOIN (SELECT ProductVariationId,MAX(ClosingUnits) AS ClosingUnits FROM ShiftLubeandLpg GROUP BY ProductVariationId) AS LastClosing ON SPV.ProductVariationId = LastClosing.ProductVariationId
					WHERE PL.IsDefault = 1 AND PC.CategoryId!=(SELECT PC.CategoryId FROM Productcategory PC WHERE PC.Categoryname='Fuel(Petrol, Diesel,Kerosine)') AND PLP.StationId = a.StationId
					FOR JSON PATH
				) AS ShiftLubeReading,
				(
				    SELECT 0 AS ShiftLubeLpgId,0 AS ShiftId,0 AS StockTypeId,0 AS AttendantId,SPV.ProductVariationId AS ProductVariationId,SPV.Productvariationname,PC.Categoryname,COALESCE(LastClosing.ClosingUnits, 0) AS OpeningUnits,0 AS ClosingUnits,0 AS UnitsSold,PLP.ProductPrice,0 AS UnitsTotal,0 AS Createdby,0 AS Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
					FROM SystemProductvariation SPV
					LEFT JOIN ShiftLubeandLpg SLP ON SLP.ProductVariationId=SPV.ProductvariationId
					INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
					INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
					INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId = PLP.ProductvariationId
					INNER JOIN PriceList PL ON PLP.PriceListId = PL.PriceListId
					LEFT JOIN (SELECT ProductVariationId,MAX(ClosingUnits) AS ClosingUnits FROM ShiftLubeandLpg GROUP BY ProductVariationId) AS LastClosing ON SPV.ProductVariationId = LastClosing.ProductVariationId
					WHERE PL.IsDefault = 1 AND PC.CategoryId!=(SELECT PC.CategoryId FROM Productcategory PC WHERE PC.Categoryname='Fuel(Petrol, Diesel,Kerosine)') AND PLP.StationId = a.StationId
					FOR JSON PATH
				) AS ShiftLpgReading,
				(
				    SELECT 0 AS ShiftLubeLpgId,0 AS ShiftId,0 AS StockTypeId,0 AS AttendantId,SPV.ProductVariationId AS ProductVariationId,SPV.Productvariationname,PC.Categoryname,COALESCE(LastClosing.ClosingUnits, 0) AS OpeningUnits,0 AS ClosingUnits,0 AS UnitsSold,PLP.ProductPrice,0 AS UnitsTotal,0 AS Createdby,0 AS Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
					FROM SystemProductvariation SPV
					LEFT JOIN ShiftLubeandLpg SLP ON SLP.ProductVariationId=SPV.ProductvariationId
					INNER JOIN SystemProduct SP ON SPV.ProductId = SP.ProductId
					INNER JOIN Productcategory PC ON SP.CategoryId = PC.CategoryId
					INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId = PLP.ProductvariationId
					INNER JOIN PriceList PL ON PLP.PriceListId = PL.PriceListId
					LEFT JOIN (SELECT ProductVariationId,MAX(ClosingUnits) AS ClosingUnits FROM ShiftLubeandLpg GROUP BY ProductVariationId) AS LastClosing ON SPV.ProductVariationId = LastClosing.ProductVariationId
					WHERE PL.IsDefault = 1 AND PC.CategoryId!=(SELECT PC.CategoryId FROM Productcategory PC WHERE PC.Categoryname='Fuel(Petrol, Diesel,Kerosine)')AND PLP.StationId = a.StationId
					FOR JSON PATH
				) AS ShiftSparePartsData,
				(
				 SELECT SPV.Productvariationname AS ItemName,0 AS Quantity,0 AS Tax, 0 AS TaxAmount,0 AS Amount 
				 FROM PricelistPrices PLP
				 INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
				 INNER JOIN SystemProductvariation SPV ON PLP.ProductvariationId=SPV.ProductvariationId
				 WHERE PL.IsDefault=1 AND  PLP.StationId=a.StationId
				 FOR JSON PATH
				) AS Shiftdetailitems
				FROM SystemStations a
				INNER JOIN Stationshifts b ON a.StationId=b.StationId
				WHERE a.StationId=@TenantStationId
				FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER
				);
		END
		ELSE
		BEGIN
		SET @StationShiftDetails =(
				SELECT 0 AS HasPrevious ,0 as ShiftId, CONCAT('SHIFT',  a.TenantId, FORMAT(GETDATE(), 'yyyyMMdd')) AS ShiftCode,GETDATE() AS ShiftDateTime,a.StationId, a.Sname AS LocationData,'' AS CashorAccount,0 AS ShiftBalance,'' AS ShiftCategory,'' AS ShiftBankReference,'' AS ShiftReference,0 AS Createdby,0 AS Modifiedby,
				(
				   SELECT  0 AS ShiftPumpReadingId,0 AS ShiftId,PN.Pumpid AS PumpId,PN.Nozzleid AS NozzleId,SP.Pumpname AS Pumpname,SP.Pumpname+'-'+PN.Nozzle AS Warehouse,ST.ProductVariationId AS ProductVariationId,SPV.Productvariationname,PLP.ProductPrice,0 AS AttendantId,0 AS OpeningShilling,
				   0 AS ClosingShilling,0 AS TotalShilling,0 AS ShillingDifference,0 AS OpeningElectronic,0 AS ClosingElectronic,0 AS ElectronicSold,0 AS ElectronicAmount,0 AS OpeningManual,0 AS ClosingManual,0 AS ManualSold,0 AS ManualDifference,'' AS Extra,'' AS Extra1,'' AS Extra2,'' AS Extra3,
				    '' AS Extra4,'' AS Extra5,'' AS Extra6,'' AS Extra7,'' AS Extra8,'' AS Extra9,'' AS Extra10,0 AS Createdby,0 AS Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
				  	 FROM PumpNozzles PN 
					 INNER JOIN Stationpumps SP ON PN.Pumpid=SP.Pumpid
					 INNER JOIN Stationtanks ST ON SP.Tankid=ST.Tankid
					 INNER JOIN SystemProductvariation SPV ON ST.ProductvariationId=SPV.ProductvariationId
					 INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
					 INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
					  WHERE PL.IsDefault=1 AND PLP.StationId=a.StationId
				    FOR JSON PATH
				) AS ShiftPumpReading,
				(
				  SELECT 0 AS ShiftTankReadingId,0 AS ShiftId,SSD.TankId AS TankId,SSD.Name AS Tankname,0 AS AttendantId,PLP.ProductPrice,0 AS OpeningQuantity,0 AS ClosingQuantity,0 AS QuantitySold,0 AS AmountSold,'' AS Extra,'' AS Extra1,
				  '' AS Extra2,'' AS Extra3,'' AS Extra4,'' AS Extra5,'' AS Extra6,'' AS Extra7,'' AS Extra8,'' AS Extra9,'' AS Extra10,SSD.Createdby,SSD.Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
  	                 FROM Stationtanks SSD 
					 INNER JOIN SystemProductvariation SPV ON SSD.ProductvariationId=SPV.ProductvariationId
					 INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
					 INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
					 WHERE PL.IsDefault=1 AND PLP.StationId=a.StationId
				 FOR JSON PATH
				) AS ShiftTankReading,
				(
				  SELECT 0 AS ShiftLubeLpgId,0 AS ShiftId,0 AS StockTypeId,0 AS AttendantId,SPV.ProductVariationId AS ProductVariationId,SPV.Productvariationname,PC.Categoryname,0 AS OpeningUnits,0 AS ClosingUnits,0 AS UnitsSold,PLP.ProductPrice,0 AS UnitsTotal,'' AS Extra,
				  '' AS Extra1,'' AS Extra2,'' AS Extra3,'' AS Extra4,'' AS Extra5,'' AS Extra6,'' AS Extra7,'' AS Extra8,'' AS Extra9,'' AS Extra10,0 AS Createdby,0 AS Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
				  FROM SystemProductvariation SPV
				  INNER JOIN SystemProduct SP ON SPV.ProductId=SP.ProductId
				  INNER JOIN Productcategory PC  ON SP.CategoryId=PC.CategoryId
				  INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
				  INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
				  WHERE PL.IsDefault=1 AND PLP.StationId=a.StationId
				  FOR JSON PATH
				) AS ShiftLubeReading,
				(
				  SELECT 0 AS ShiftLubeLpgId,0 AS ShiftId,0 AS StockTypeId,0 AS AttendantId,SPV.ProductVariationId AS ProductVariationId,SPV.Productvariationname,PC.Categoryname,0 AS OpeningUnits,0 AS ClosingUnits,0 AS UnitsSold,PLP.ProductPrice,0 AS UnitsTotal,'' AS Extra,
				  '' AS Extra1,'' AS Extra2,'' AS Extra3,'' AS Extra4,'' AS Extra5,'' AS Extra6,'' AS Extra7,'' AS Extra8,'' AS Extra9,'' AS Extra10,0 AS Createdby,0 AS Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
				  FROM SystemProductvariation SPV
				  INNER JOIN SystemProduct SP ON SPV.ProductId=SP.ProductId
				  INNER JOIN Productcategory PC  ON SP.CategoryId=PC.CategoryId
				  INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
				  INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
				  WHERE PL.IsDefault=1 AND PLP.StationId=a.StationId
				  FOR JSON PATH
				) AS ShiftLpgReading,
				(
				  SELECT 0 AS ShiftLubeLpgId,0 AS ShiftId,0 AS StockTypeId,0 AS AttendantId,SPV.ProductVariationId  AS ProductVariationId,SPV.Productvariationname,PC.Categoryname,0 AS OpeningUnits,0 AS ClosingUnits,0 AS UnitsSold,PLP.ProductPrice,0 AS UnitsTotal,'' AS Extra,
				  '' AS Extra1,'' AS Extra2,'' AS Extra3,'' AS Extra4,'' AS Extra5,'' AS Extra6,'' AS Extra7,'' AS Extra8,'' AS Extra9,'' AS Extra10,0 AS Createdby,0 AS Modifiedby,GETDATE() AS Datemodified,GETDATE() AS Datecreated
				  FROM SystemProductvariation SPV
				  INNER JOIN SystemProduct SP ON SPV.ProductId=SP.ProductId
				  INNER JOIN Productcategory PC  ON SP.CategoryId=PC.CategoryId
				  INNER JOIN PricelistPrices PLP ON SPV.ProductvariationId=PLP.ProductvariationId
				  INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
				  WHERE PL.IsDefault=1 AND PLP.StationId=a.StationId
				  FOR JSON PATH
				) AS ShiftSparePartsData,
				(
				 SELECT SPV.Productvariationname AS ItemName,0 AS Quantity,0 AS Tax, 0 AS TaxAmount,0 AS Amount 
				 FROM PricelistPrices PLP
				 INNER JOIN PriceList PL ON PLP.PriceListId=PL.PriceListId
				 INNER JOIN SystemProductvariation SPV ON PLP.ProductvariationId=SPV.ProductvariationId
				 WHERE PL.IsDefault=1 AND  PLP.StationId=a.StationId
				 FOR JSON PATH
				) AS Shiftdetailitems
				FROM SystemStations a
				WHERE a.StationId=@TenantStationId
				FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		  )
		 END
		END

	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
			SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@StationShiftDetails as StationShiftDetails;
		END TRY
		BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ''
		PRINT 'Error ' + error_message();
		Select 2 as RespStatus, '0 - Error(s) Occurred' + error_message() as RespMessage
		END CATCH
		Select @RespStat as RespStatus, @RespMsg as RespMessage;
		RETURN; 
		END;
	END
END