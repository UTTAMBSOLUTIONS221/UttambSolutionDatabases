CREATE PROCEDURE [dbo].[Usp_Registersystemstationshiftcreditinvoicedata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
			MERGE INTO ShiftCreditInvoices AS target USING (
			SELECT ShiftCreditInvoiceId,ShiftId,AttendantId,CustomerId,EquipmentId,ProductVariationId,ProductUnits,ProductPrice,ProductDiscount,ProductTotal,VatTotal,RecieptNumber,OrderNumber,Reference,Createdby,Modifiedby,DateCreated,DateModified
			FROM OPENJSON(@JsonObjectdata)
			WITH (ShiftCreditInvoiceId BIGINT '$.ShiftCreditInvoiceId',ShiftId BIGINT '$.ShiftId',AttendantId BIGINT '$.AttendantId',CustomerId BIGINT '$.CustomerId',
			EquipmentId BIGINT '$.EquipmentId',ProductVariationId BIGINT '$.ProductVariationId',ProductUnits DECIMAL(18, 2) '$.ProductUnits',ProductPrice DECIMAL(18, 2) '$.ProductPrice',ProductDiscount DECIMAL(18, 2) '$.ProductDiscount',ProductTotal DECIMAL(18, 2) '$.ProductTotal',
			VatTotal  DECIMAL(18, 2) '$.VatTotal',RecieptNumber VARCHAR(100) '$.RecieptNumber',OrderNumber VARCHAR(100) '$.OrderNumber',Reference VARCHAR(100) '$.Reference',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',DateCreated DATETIME '$.DateCreated',DateModified DATETIME '$.DateModified'
			)) AS source ON target.ShiftCreditInvoiceId = source.ShiftCreditInvoiceId 
		   WHEN MATCHED THEN
		   UPDATE SET target.ShiftId = source.ShiftId,target.AttendantId = source.AttendantId,target.CustomerId = source.CustomerId,target.EquipmentId = source.EquipmentId,target.ProductVariationId = source.ProductVariationId,target.ProductUnits = source.ProductUnits,target.ProductPrice = source.ProductPrice,
		   target.ProductDiscount = source.ProductDiscount,target.ProductTotal = source.ProductTotal,target.VatTotal = source.VatTotal,target.RecieptNumber = source.RecieptNumber,target.OrderNumber = source.OrderNumber,target.Reference = source.Reference,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
		   WHEN NOT MATCHED BY TARGET THEN
		   INSERT (ShiftId,AttendantId,CustomerId,EquipmentId,ProductVariationId,ProductUnits,ProductPrice,ProductDiscount,ProductTotal,VatTotal,RecieptNumber,OrderNumber,Reference,Createdby,Modifiedby,DateCreated,DateModified) 
		   VALUES (source.ShiftId,source.AttendantId,source.CustomerId,source.EquipmentId,source.ProductVariationId,source.ProductUnits,source.ProductPrice,source.ProductDiscount,source.ProductTotal,source.VatTotal,source.RecieptNumber,source.OrderNumber,source.Reference,source.Createdby,source.Modifiedby,source.DateCreated,source.DateModified);


		--		MERGE INTO ShiftCreditInvoices AS target
		--	USING (SELECT ShiftCreditInvoiceId,ShiftId,AttendantId,CustomerId,EquipmentId,ProductVariationId,ProductUnits,ProductPrice,ProductDiscount,ProductTotal,Reference,Createdby,Modifiedby,DateCreated,DateModified
		--	FROM OPENJSON(@JsonObjectdata, '$.ShiftCreditInvoice')
		--	WITH (ShiftCreditInvoiceId BIGINT '$.ShiftCreditInvoiceId',ShiftId BIGINT '$.ShiftId',AttendantId BIGINT '$.AttendantId',CustomerId BIGINT '$.CustomerId',EquipmentId BIGINT '$.EquipmentId',ProductVariationId BIGINT '$.ProductVariationId',
		--	ProductUnits DECIMAL(18, 2) '$.ProductUnits',ProductPrice DECIMAL(18, 2) '$.ProductPrice',ProductDiscount DECIMAL(18, 2) '$.ProductDiscount',ProductTotal DECIMAL(18, 2) '$.ProductTotal',Reference VARCHAR(100) '$.Reference',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',DateCreated DATETIME '$.DateCreated',DateModified DATETIME '$.DateModified'
		--	)) AS source ON target.ShiftCreditInvoiceId = source.ShiftCreditInvoiceId WHEN MATCHED THEN
		--	UPDATE SET target.ShiftId = source.ShiftId,target.AttendantId = source.AttendantId,target.CustomerId = source.CustomerId,target.EquipmentId = source.EquipmentId,target.ProductVariationId = source.ProductVariationId,target.ProductUnits = source.ProductUnits,target.ProductPrice = source.ProductPrice,
		--	target.ProductDiscount = source.ProductDiscount,target.ProductTotal = source.ProductTotal,target.Reference = source.Reference,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
		--	WHEN NOT MATCHED BY TARGET THEN
		--	INSERT (ShiftId,AttendantId,CustomerId,EquipmentId,ProductVariationId,ProductUnits,ProductPrice,ProductDiscount,ProductTotal,Reference,Createdby,Modifiedby,DateCreated,DateModified) 
		--	VALUES (source.ShiftId,source.AttendantId,source.CustomerId,source.EquipmentId,source.ProductVariationId,source.ProductUnits,source.ProductPrice,source.ProductDiscount,source.ProductTotal,source.Reference,source.Createdby,source.Modifiedby,source.DateCreated,source.DateModified);
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage;

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