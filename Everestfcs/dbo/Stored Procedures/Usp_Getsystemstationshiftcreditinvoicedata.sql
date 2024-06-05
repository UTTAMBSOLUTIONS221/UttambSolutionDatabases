CREATE PROCEDURE [dbo].[Usp_Getsystemstationshiftcreditinvoicedata]
@ShiftId BIGINT,
@start INT,
@length INT,
@searchParam VARCHAR(100),
@DataTableData NVARCHAR(MAX) OUTPUT
AS
BEGIN
SET @DataTableData=(
		SELECT COUNT(SCC.ShiftCreditInvoiceId) AS RecordsTotal,(SELECT SCI.ShiftCreditInvoiceId,SCI.ShiftId,SCI.AttendantId,SST.FirstName +' '+SST.LastName AS AttendantName,SCI.CustomerId,CASE WHEN C.Designation='Corporate' THEN C.Companyname ELSE C.Firstname+' '+ C.Lastname END AS CustomerName,
		SCI.EquipmentId,CE.EquipmentRegNo AS EquipmentNo,SCI.ProductVariationId,SP.ProductVariationName AS ProductVariationName,SCI.ProductUnits,SCI.ProductPrice,SCI.ProductDiscount,SCI.ProductTotal,SCI.VatTotal,ISNULL(SCI.Reference,'N/A') AS Reference,ISNULL(SCI.OrderNumber,'N/A') AS OrderNumber,ISNULL(SCI.RecieptNumber,'N/A') AS RecieptNumber,SCI.Extra,SCI.Extra1,SCI.Extra2,
		SCI.Extra3,SCI.Extra4,SCI.Extra5,SCI.Extra6,SCI.Extra7,SCI.Extra8,SCI.Extra9,SCI.Extra10,SCI.Createdby,SCI.Modifiedby,SCI.Datemodified,SCI.Datecreated
		FROM ShiftCreditInvoices SCI
		INNER JOIN Stationshifts SS ON SCI.ShiftId=SS.ShiftId
		INNER JOIN SystemStaffs SST ON SCI.AttendantId=SST.UserId
		INNER JOIN Customers C ON SCI.CustomerId=C.CustomerId
		INNER JOIN SystemProductvariation SP ON SCI.ProductVariationId=SP.ProductVariationId
		INNER JOIN CustomerEquipments CE ON SCI.EquipmentId=CE.EquipmentId 
		WHERE SCI.ShiftId=SCC.ShiftId
		ORDER BY SCI.ShiftCreditInvoiceId DESC 
		OFFSET @start ROWS FETCH NEXT @length ROWS ONLY
		FOR JSON PATH
		) AS DataTableData
		FROM ShiftCreditInvoices SCC
		WHERE SCC.ShiftId=@ShiftId 
		GROUP BY SCC.ShiftId
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER
	)
END