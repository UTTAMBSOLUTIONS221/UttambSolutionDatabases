CREATE PROCEDURE [dbo].[Usp_Getsystemstationshiftwetstockpurchasedata]
@ShiftId BIGINT,
@start INT,
@length INT,
@searchParam VARCHAR(100),
@ShiftWetStockPurchases NVARCHAR(MAX) OUTPUT
AS
BEGIN
SET @ShiftWetStockPurchases=(
        SELECT (SELECT COUNT(*) FROM ShiftPurchasesItems SDI WHERE SDI.PurchaseId = SDT.PurchaseId) AS RecordsTotal,SDT.PurchaseId,SDT.ShiftId,SDT.InvoiceNumber,SDT.SupplierId,SSP.SupplierName,SDT.InvoiceAmount,SDT.TransportAmount,SDT.InvoiceDate,SDT.TruckNumber,SDT.DriverName,SDT.Extra,SDT.Extra1,SDT.Extra2,SDT.Extra3,SDT.Extra4,SDT.Extra5,SDT.Extra6,SDT.Extra7,SDT.Extra8,SDT.Extra9,SDT.Extra10,SDT.Createdby,SDT.Modifiedby,SDT.Datemodified,SDT.Datecreated,
		(SELECT SDTI.PurchaseItemId,SDTI.PurchaseId,SDTI.ProductVariationId,SPV.ProductVariationName,SDTI.TankId,ST.Name AS TankName,SDTI.DipsBeforeOffloading,SDTI.PurchaseQuantity,SDTI.DipsAfterOffloading,SDTI.ExpectedQuantity,SDTI.Gainloss,SDTI.PercentGainloss,SDTI.PurchasePrice,SDTI.PurchaseTax,SDTI.PurchaseDiscount,SDTI.PurchaseGTotal,SDTI.PurchaseNTotal,SDTI.PurchaseTaxAmount,SDTI.Extra,SDTI.Extra1,SDTI.Extra2,SDTI.Extra3,SDTI.Extra4,SDTI.Extra5,SDTI.Extra6,SDTI.Extra7,SDTI.Extra8,SDTI.Extra9,SDTI.Extra10,SDTI.Createdby,SDTI.Modifiedby,SDTI.Datemodified,SDTI.Datecreated
		FROM ShiftPurchasesItems SDTI
		INNER JOIN SystemProductVariation SPV ON SDTI.ProductVariationId = SPV.ProductVariationId
		INNER JOIN StationTanks ST ON SDTI.TankId = ST.TankId
		WHERE SDTI.PurchaseId = SDT.PurchaseId 
		ORDER BY SDTI.PurchaseItemId DESC 
		OFFSET @start ROWS 
		FETCH NEXT @length ROWS ONLY 
		FOR JSON PATH
		) AS ShiftWetStockPurchases
		FROM ShiftPurchases SDT
		INNER JOIN StationShifts SSH ON SDT.ShiftId = SSH.ShiftId
		INNER JOIN SystemSuppliers SSP ON SDT.SupplierId = SSP.SupplierId
		WHERE SDT.WetDryPurchase = 'WetStockPurchase' AND SDT.ShiftId = @ShiftId
		FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
	)
END