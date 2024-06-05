CREATE PROCEDURE [dbo].[Usp_ReportShiftCashDrops] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftCashDropsDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
    SELECT @ShiftCashDropsDetailsJson =	
	        (SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
            (SELECT SE.ShiftVoucherId,SE.ShiftId,SS.ShiftCode,SS.ShiftDateTime,SE.AttendantId,STF.Firstname+' '+STF.Lastname AS AttendantName,SE.VoucherType,SE.CreditDebit,SE.VoucherModeId,CASE WHEN PYM.Paymentmode='MPesa' THEN 'LIPA NA MPESA' ELSE PYM.Paymentmode END AS VoucherMode,SE.VoucherName,SE.ProductVariationId,SPV.Barcode AS ProductCode , SPV.Productvariationname,SE.ProductQuantity,SE.ProductPrice,SE.ProductDiscount,SE.VoucherAmount,SE.VatAmount,SE.RecieptNumber,SE.CardNumber,CR.Firstname+' '+CR.Lastname AS CreatedByName,SE.Modifiedby,MR.Firstname+' '+MR.Lastname AS ModifiedByName,SE.Datemodified,SE.Datecreated
			FROM ShiftVouchers SE
			INNER JOIN Stationshifts SS ON SE.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemProductvariation SPV ON SE.ProductVariationId=SPV.ProductvariationId
			INNER JOIN SystemStaffs STF ON SE.AttendantId=STF.Userid
			INNER JOIN Paymentmodes PYM ON SE.VoucherModeId=PYM.PaymentmodeId
			INNER JOIN SystemStaffs CR ON SE.Createdby=CR.Userid  
			INNER JOIN SystemStaffs MR ON SE.Createdby=MR.Userid    
			WHERE SE.VoucherType!='ShiftExpenses' AND STS.Tenantid=JSON_VALUE(@JsonObjectdata, '$.TenantId') AND (JSON_VALUE(@JsonObjectdata, '$.Station') < 1 OR STS.StationId = JSON_VALUE(@JsonObjectdata, '$.Station')) 
            AND (JSON_VALUE(@JsonObjectdata, '$.Shift') < 1  OR SE.ShiftId = JSON_VALUE(@JsonObjectdata, '$.Shift')) AND (SE.AttendantId=JSON_VALUE(@JsonObjectdata, '$.Attendant') OR JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1)
            AND SE.Datecreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AND TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))
			 FOR JSON PATH
			) AS ShiftCashDrop
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );
END