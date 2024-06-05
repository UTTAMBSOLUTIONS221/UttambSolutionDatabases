CREATE PROCEDURE [dbo].[Usp_ReportShiftpurchasesReading] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftpurchasesDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
    SELECT @ShiftpurchasesDetailsJson = (SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
           (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
           (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
           (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
           (SELECT SS.ShiftCode, SS.ShiftDateTime, SP.WetDryPurchase,SP.InvoiceNumber,SSP.SupplierName,SP.InvoiceAmount,SP.TransportAmount,SP.InvoiceDate,SP.TruckNumber,SP.DriverName,CR.Firstname+' '+CR.Lastname AS CreatedByName,MR.Firstname+' '+MR.Lastname AS ModifiedByName,SP.Datemodified,SP.Datecreated,
	       (SELECT SPV.Productvariationname,ISNULL(ST.Name,'N/A') AS TankName,SPI.DipsBeforeOffloading,SPI.DipsAfterOffloading,SPI.ExpectedQuantity,SPI.Gainloss,SPI.PercentGainloss,
			SPI.PurchaseQuantity,SPI.PurchasePrice,SPI.PurchaseTax,SPI.PurchaseDiscount,SPI.PurchaseGTotal,SPI.PurchaseNTotal,SPI.PurchaseTaxAmount,CR.Firstname+' '+CR.Lastname AS CreatedByName,MR.Firstname+' '+MR.Lastname AS ModifiedByName,SPI.Datemodified,SPI.Datecreated
			FROM ShiftPurchasesItems SPI
			LEFT JOIN Stationtanks ST ON SPI.TankId=ST.Tankid
			INNER JOIN SystemProductVariation SPV ON SPI.ProductVariationId=SPV.ProductVariationId
			INNER JOIN SystemStaffs CR ON SPI.Createdby=CR.Userid  
			INNER JOIN SystemStaffs MR ON SPI.Createdby=MR.Userid
			WHERE SP.PurchaseId=SPI.PurchaseId
			 FOR JSON PATH
			) AS PurchaseItems
		FROM ShiftPurchases SP
		INNER JOIN SystemSuppliers SSP ON SP.SupplierId=SSP.SupplierId
		INNER JOIN Stationshifts SS ON SP.ShiftId=SS.ShiftId
		INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
		INNER JOIN SystemStaffs CR ON SP.Createdby=CR.Userid  
		INNER JOIN SystemStaffs MR ON SP.Createdby=MR.Userid
		 WHERE SP.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AND (SP.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift') OR 0=JSON_VALUE(@JsonObjectdata, '$.Shift'))
			  AND (SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station') OR 0=JSON_VALUE(@JsonObjectdata, '$.Station')) AND (SP.Createdby=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR 0=JSON_VALUE(@JsonObjectdata, '$.Attendant'))
		
		FOR JSON PATH
		) AS Purchases
	   FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
     );
END