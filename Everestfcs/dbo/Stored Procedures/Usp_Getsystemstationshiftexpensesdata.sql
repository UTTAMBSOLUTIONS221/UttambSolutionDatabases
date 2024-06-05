CREATE PROCEDURE [dbo].[Usp_Getsystemstationshiftexpensesdata]
@ShiftId BIGINT,
@start INT,
@length INT,
@searchParam VARCHAR(100),
@DataTableData NVARCHAR(MAX) OUTPUT
AS
BEGIN
SET @DataTableData=(
		SELECT COUNT(ISNULL(SCC.ShiftVoucherId,0)) AS RecordsTotal,(SELECT SVV.ShiftVoucherId,SVV.ShiftId,SVV.AttendantId,SST.FirstName +' '+SST.LastName AS AttendantName,SVV.VoucherType,SVV.CreditDebit,SVV.VoucherModeId,PYM.Paymentmode AS VoucherModeName,SVV.VoucherName,
				  SVV.VoucherAmount,SVV.Extra,SVV.Extra1,SVV.Extra2,SVV.Extra3,SVV.Extra4,SVV.Extra5,SVV.Extra6,SVV.Extra7,SVV.Extra8,SVV.Extra9,SVV.Extra10,SVV.Createdby,SVV.Modifiedby,SVV.Datemodified,SVV.Datecreated
				  FROM ShiftVouchers SVV
				  INNER JOIN Stationshifts SS ON SVV.ShiftId=SS.ShiftId
				  INNER JOIN SystemStaffs SST  ON SVV.AttendantId=SST.UserId
				  INNER JOIN Paymentmodes PYM ON SVV.VoucherModeId=PYM.PaymentModeId 
		WHERE SVV.VoucherType='ShiftExpenses' AND SVV.ShiftId=SCC.ShiftId
		ORDER BY SVV.ShiftVoucherId DESC 
		OFFSET @start ROWS FETCH NEXT @length ROWS ONLY
		FOR JSON PATH
		) AS DataTableData
		FROM ShiftVouchers SCC  
		WHERE SCC.VoucherType='ShiftExpenses' AND SCC.ShiftId=@ShiftId 
		GROUP BY SCC.ShiftId
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER
	)
END