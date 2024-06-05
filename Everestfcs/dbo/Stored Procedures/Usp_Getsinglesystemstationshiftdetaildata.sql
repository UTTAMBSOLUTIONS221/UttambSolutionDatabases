
CREATE PROCEDURE [dbo].[Usp_Getsinglesystemstationshiftdetaildata]
	@StationShiftId BIGINT,
	@StationShiftDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	
		BEGIN TRANSACTION;	
		SET @StationShiftDetails =(
		SELECT SSD.ShiftDataId,SSD.ShiftId,SSD.NozzleId,SSD.AttendantId,SSD.PumpId,SSD.ProductvariationId,SSD.OpeningRead,SSD.ClosingRead,SSD.SaleQuantity,SSD.ProductPrice,SSD.TestingQuantity,SSD.GeneratorQuantity,SSD.GainOrLoss,
			SSD.TaxRate,SSD.TaxAmount,SSD.TotalAmount,SSD.Extra,SSD.Extra1,SSD.Extra2,SSD.Extra3,SSD.Extra4,SSD.Extra5,SSD.Extra6,SSD.Extra7,SSD.Extra8,SSD.Extra9,SSD.Extra10,SSD.Createdby,SSD.Modifiedby,SSD.Datemodified,SSD.Datecreated,
			(
				SELECT a.ShiftLubeLpgId,a.ShiftId,a.AttendantId,b.FirstName+' '+b.LastName AS AttendantName,a.ProductVariationId,c.ProductVariationName,pc.CategoryName,a.ProductUnits,a.ProductPrice,a.ProductTotal,
				a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Createdby,
				d.FirstName+' '+d.LastName AS CreatedbyName,a.Modifiedby,e.FirstName+' '+e.LastName AS ModifiedbyName,a.Datemodified,a.Datecreated
				FROM ShiftLubeandLpg a
				INNER JOIN SystemStaffs b ON a.AttendantId=b.UserId
				INNER JOIN SystemProductvariation c ON a.ProductVariationId=c.ProductVariationId
				INNER JOIN SystemProduct sp ON sp.ProductId=c.ProductId
				INNER JOIN ProductCategory pc ON sp.CategoryId=pc.CategoryId
				INNER JOIN SystemStaffs d ON a.Createdby=d.UserId
				INNER JOIN SystemStaffs e ON a.Createdby=e.UserId
				WHERE a.ShiftId=SSD.ShiftId
				FOR JSON PATH 
			) AS ShiftLubeandLpg,
			(
				SELECT aaa.ShiftVoucherId,aaa.ShiftId,aaa.AttendantId,b.FirstName + ' ' + b.LastName AS AttendantName, CASE WHEN aaa.VoucherType='Contra' THEN 'Cash Recieved' ELSE aaa.VoucherType END AS VoucherType,aaa.VoucherModeId,c.PaymentMode,aaa.VoucherName,
				CASE WHEN aaa.CreditDebit = 'Credit' THEN aaa.VoucherAmount ELSE 0 END AS CreditAmount,CASE WHEN aaa.CreditDebit = 'Debit' THEN aaa.VoucherAmount ELSE 0 END AS DebitAmount,aaa.CreditDebit,
				aaa.Extra,aaa.Extra1,aaa.Extra2,aaa.Extra3,aaa.Extra4,aaa.Extra5,aaa.Extra6,aaa.Extra7,aaa.Extra8,aaa.Extra9,aaa.Extra10,aaa.Createdby,d.FirstName+' '+d.LastName AS CreatedbyName,aaa.Modifiedby,e.FirstName+' '+e.LastName AS ModifiedbyName,aaa.Datemodified,aaa.Datecreated
				FROM ShiftVouchers aaa
				INNER JOIN SystemStaffs b ON aaa.AttendantId = b.UserId
				INNER JOIN Paymentmodes c ON aaa.VoucherModeId = c.PaymentModeId
				INNER JOIN SystemStaffs d ON aaa.Createdby = d.UserId
				INNER JOIN SystemStaffs e ON aaa.Createdby = e.UserId
				WHERE aaa.ShiftId=SSD.ShiftId
				FOR JSON PATH 
			) AS ShiftVouchers,
			(
				SELECT aa.ShiftCreditInvoiceId,aa.ShiftId,SSH.ShiftStatus,aa.AttendantId,b.FirstName+' '+b.LastName AS AttendantName,aa.CustomerId,CASE WHEN f.Designation='Corporate' THEN f.Companyname ELSE f.Firstname+' '+ f.Lastname END AS Customername,aa.EquipmentId,g.EquipmentRegNo,aa.ProductVariationId,c.ProductVariationName,aa.ProductUnits,aa.ProductPrice,aa.ProductDiscount,aa.ProductTotal,
				aa.Extra,aa.Extra1,aa.Extra2,aa.Extra3,aa.Extra4,aa.Extra5,aa.Extra6,aa.Extra7,aa.Extra8,aa.Extra9,aa.Extra10,aa.Createdby,d.FirstName+' '+d.LastName AS CreatedbyName,aa.Modifiedby,e.FirstName+' '+e.LastName AS ModifiedbyName,aa.Datemodified,aa.Datecreated
				FROM ShiftCreditInvoices aa
				INNER JOIN SystemStaffs b ON aa.AttendantId=b.UserId
				INNER JOIN SystemProductvariation c ON aa.ProductVariationId=c.ProductVariationId
				INNER JOIN SystemStaffs d ON aa.Createdby=d.UserId
				INNER JOIN SystemStaffs e ON aa.Createdby=e.UserId
				INNER JOIN Customers f ON aa.Customerid=f.CustomerId
				INNER JOIN CustomerEquipments g ON g.EquipmentId=aa.EquipmentId
				WHERE aa.ShiftId=SSD.ShiftId
				FOR JSON PATH 
			) AS ShiftCreditInvoices
			FROM StationshiftsData SSD
			INNER JOIN StationShifts SSH ON SSD.ShiftId=SSH.ShiftId
			WHERE SSD.ShiftDataId=@StationShiftId
		   FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
	     )

	    Set @RespMsg ='Success'
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