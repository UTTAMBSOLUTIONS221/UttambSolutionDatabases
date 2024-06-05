CREATE PROCEDURE [dbo].[Usp_Getsystemstationshiftpaymentdata]
@ShiftId BIGINT,
@start INT,
@length INT,
@searchParam VARCHAR(100),
@DataTableData NVARCHAR(MAX) OUTPUT
AS
BEGIN
SET @DataTableData=(
		SELECT COUNT(ISNULL(SCC.ShiftPaymentId,0)) AS RecordsTotal,(SELECT STP.ShiftPaymentId,STP.ShiftId,STP.AttendantId,SST.FirstName +' '+SST.LastName AS AttendantName,STP.CustomerId,CASE WHEN C.Designation='Corporate' THEN C.Companyname ELSE C.Firstname+' '+ C.Lastname END AS CustomerName,
		STP.PaymentModeId,PM.Paymentmode AS PaymentMode,STP.PaymentAmount,STP.PaymentReference,STP.IsReversed,STP.Createdby,STP.Modifiedby,STP.DateCreated,STP.DateModified
		FROM ShiftPayment STP
		INNER JOIN Stationshifts SS ON STP.ShiftId=SS.ShiftId
		INNER JOIN SystemStaffs SST  ON STP.AttendantId=SST.UserId
	 	INNER JOIN Customers C  ON STP.CustomerId=C.CustomerId
		INNER JOIN Paymentmodes PM  ON STP.PaymentModeId=PM.PaymentModeId
		WHERE STP.ShiftId=SCC.ShiftId
		ORDER BY STP.ShiftPaymentId DESC 
		OFFSET @start ROWS FETCH NEXT @length ROWS ONLY
		FOR JSON PATH
		) AS DataTableData
		FROM ShiftPayment SCC  
		WHERE SCC.ShiftId=@ShiftId 
		GROUP BY SCC.ShiftId
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER
	)
END