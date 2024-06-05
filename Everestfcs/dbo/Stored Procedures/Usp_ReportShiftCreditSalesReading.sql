CREATE PROCEDURE [dbo].[Usp_ReportShiftCreditSalesReading] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftCreditSalesDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
    SELECT @ShiftCreditSalesDetailsJson = 
			(SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
            (SELECT SS.ShiftCode,SS.ShiftDateTime,SCS.AttendantId,STF.Firstname+' '+STF.Lastname AS AttendantName,SCS.CustomerId,CASE WHEN CS.Designation='Corporate' THEN CS.Companyname ELSE CS.Firstname+' '+ CS.Lastname END AS CustomerName,SCS.EquipmentId,ISNULL(CE.EquipmentRegNo,'N/A') AS EquipmentNo,
			SCS.ProductVariationId,SPV.Barcode AS ProductCode,SPV.ProductVariationName,SCS.ProductUnits,SCS.ProductPrice,SCS.ProductDiscount,SCS.ProductTotal,SCS.VatTotal,SCS.RecieptNumber,SCS.OrderNumber,SCS.Reference,SCS.Createdby,CR.Firstname+' '+CR.Lastname AS CreatedByName,SCS.Modifiedby,MR.Firstname+' '+MR.Lastname AS ModifiedByName,SCS.Datemodified,SCS.Datecreated
			FROM ShiftCreditInvoices SCS
			INNER JOIN SystemProductVariation SPV ON SCS.ProductVariationId=SPV.ProductVariationId
			INNER JOIN Customers CS ON SCS.CustomerId=CS.CustomerId
			LEFT JOIN CustomerEquipments CE ON SCS.EquipmentId=CE.EquipmentId 
			INNER JOIN Stationshifts SS ON SCS.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemStaffs STF ON SCS.AttendantId=STF.Userid
			INNER JOIN SystemStaffs CR ON SCS.Createdby=CR.Userid  
			INNER JOIN SystemStaffs MR ON SCS.Createdby=MR.Userid 
			WHERE  STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SCS.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SCS.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SCS.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			 FOR JSON PATH
			) AS ShiftCreditsales
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );
END