CREATE PROCEDURE [dbo].[Usp_ReportShiftExpenses] 
    @JsonObjectdata VARCHAR(MAX),
    @ShiftExpensesDetailsJson VARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;  
    IF 1=0 BEGIN  
        SET FMTONLY OFF  
    END;
    SELECT @ShiftExpensesDetailsJson =    
	        (SELECT TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END) AS StationName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Shift') < 1 THEN 'ALL' ELSE (SELECT SS.ShiftCode FROM StationShifts SS WHERE SS.ShiftId=JSON_VALUE(@JsonObjectdata, '$.Shift')) END) AS ShiftCode,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT STF.Firstname+' '+STF.Lastname FROM SystemStaffs STF WHERE STF.Userid=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END) AS AttendantName,
            (SELECT SE.ShiftVoucherId,SE.ShiftId,SS.ShiftCode,SS.ShiftDateTime,SE.AttendantId,STF.Firstname+' '+STF.Lastname AS AttendantName,
			SE.VoucherType,SE.CreditDebit,SE.VoucherModeId,PYM.Paymentmode AS VoucherMode,SE.VoucherName,SE.VoucherAmount,SE.Createdby,
			CR.Firstname+' '+CR.Lastname AS CreatedByName,SE.Modifiedby,MR.Firstname+' '+MR.Lastname AS ModifiedByName,SE.Datemodified,SE.Datecreated
			FROM ShiftVouchers SE
			INNER JOIN Stationshifts SS ON SE.ShiftId=SS.ShiftId
			INNER JOIN SystemStations STS ON SS.StationId=STS.StationId
			INNER JOIN SystemStaffs STF ON SE.AttendantId=STF.Userid
			INNER JOIN Paymentmodes PYM ON SE.VoucherModeId=PYM.PaymentmodeId
			INNER JOIN SystemStaffs CR ON SE.Createdby=CR.Userid  
			INNER JOIN SystemStaffs MR ON SE.Createdby=MR.Userid  
			WHERE SE.VoucherType='ShiftExpenses' AND STS.Tenantid=2 AND SE.ShiftId=1 
			FOR JSON PATH
			) AS ShiftExpenses
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
          );
END