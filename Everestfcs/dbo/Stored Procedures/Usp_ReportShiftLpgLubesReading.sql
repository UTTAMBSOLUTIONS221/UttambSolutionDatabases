CREATE PROCEDURE [dbo].[Usp_ReportShiftLpgLubesReading] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftLpgLubeReadingDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
    SELECT @ShiftLpgLubeReadingDetailsJson = 
	        (SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
            (SELECT SLR.ShiftLubeLpgId,SLR.ShiftId,SS.ShiftCode,SS.ShiftDateTime,SLR.StockTypeId,SLR.AttendantId,STF.Firstname+' '+STF.Lastname AS AttendantName,SLR.ProductVariationId,SPV.Barcode AS ProductCode,SPV.ProductVariationName,SLR.OpeningUnits,(SELECT ISNULL(SUM(DSM.Quantity),0) FROM DryStockMovement DSM WHERE DSM.ShiftId=SLR.ShiftId AND DSM.ProductVariationId=SLR.ProductVariationId) AS AddedUnits,SLR.ClosingUnits,SLR.UnitsSold,SLR.ProductPrice,SLR.UnitsTotal, 0 AS TotalVat,SLR.Createdby,CR.Firstname+' '+CR.Lastname AS CreatedByName,SLR.Modifiedby,MR.Firstname+' '+MR.Lastname AS ModifiedByName,SLR.Datemodified,SLR.Datecreated
			FROM ShiftLubeandLpg SLR
			INNER JOIN SystemProductVariation SPV ON SLR.ProductVariationId=SPV.ProductVariationId
			INNER JOIN Stationshifts SS ON SLR.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemStaffs STF ON SLR.AttendantId=STF.Userid
			INNER JOIN SystemStaffs CR ON SLR.Createdby=CR.Userid  
			INNER JOIN SystemStaffs MR ON SLR.Createdby=MR.Userid
			WHERE STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SLR.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SLR.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant')<1)
            AND SLR.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			FOR JSON PATH
			) AS ShiftLpgLubeReading,
			(   
				SELECT SPV.Productvariationname AS Product,PC.Categoryname AS Category, SUM(LUBE.UnitsTotal) AS DryTotalAmount
				FROM ShiftLubeandLpg LUBE
				INNER JOIN SystemProductvariation SPV ON LUBE.Productvariationid = SPV.ProductvariationId
				INNER JOIN SystemProduct SP ON SPV.ProductId=SP.ProductId
				INNER JOIN Productcategory PC ON SP.CategoryId=PC.CategoryId
				GROUP BY  SPV.Productvariationname,PC.Categoryname
				FOR JSON PATH
				) AS LpgLubeReadings
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );
END