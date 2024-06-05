CREATE PROCEDURE [dbo].[Usp_Registersystemstationshiftmerchantdata]
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
			MERGE INTO ShiftVouchers AS target USING (
			SELECT ShiftVoucherId,ShiftId,AttendantId,VoucherType,CreditDebit,VoucherModeId,VoucherName,ProductVariationId,ProductQuantity,ProductPrice,ProductDiscount,VoucherAmount,VatAmount,CardNumber,RecieptNumber,Createdby,Modifiedby,Datemodified,Datecreated
			FROM OPENJSON(@JsonObjectdata)
			WITH (ShiftVoucherId BIGINT '$.ShiftVoucherId',ShiftId BIGINT '$.ShiftId',AttendantId BIGINT '$.AttendantId',VoucherType VARCHAR(50) '$.VoucherType',CreditDebit VARCHAR(50) '$.CreditDebit',VoucherModeId BIGINT '$.VoucherModeId',VoucherName VARCHAR(100) '$.VoucherName',
			ProductVariationId BIGINT '$.ProductVariationId',ProductQuantity DECIMAL(18, 2) '$.ProductQuantity',ProductPrice DECIMAL(18, 2) '$.ProductPrice',ProductDiscount DECIMAL(18, 2) '$.ProductDiscount',VoucherAmount DECIMAL(18, 2) '$.VoucherAmount',
			VatAmount DECIMAL(18, 2) '$.VatAmount',CardNumber VARCHAR(100) '$.CardNumber',RecieptNumber VARCHAR(100) '$.RecieptNumber',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',Datemodified DATETIME '$.DateModified',Datecreated DATETIME '$.DateCreated'
			)) AS source ON target.ShiftVoucherId = source.ShiftVoucherId
			WHEN MATCHED THEN
			UPDATE SET target.ShiftId = source.ShiftId,target.AttendantId = source.AttendantId,target.VoucherType = source.VoucherType,target.CreditDebit = source.CreditDebit,target.VoucherModeId = source.VoucherModeId,target.VoucherName = source.VoucherName,target.ProductVariationId = source.ProductVariationId,
			target.ProductQuantity = source.ProductQuantity,target.ProductPrice = source.ProductPrice,target.ProductDiscount = source.ProductDiscount,target.VoucherAmount = source.VoucherAmount,
			target.VatAmount = source.VatAmount,target.CardNumber = source.CardNumber,target.RecieptNumber = source.RecieptNumber,target.Modifiedby = source.Modifiedby,target.Datemodified = source.Datemodified
			WHEN NOT MATCHED BY TARGET THEN
			INSERT (ShiftId,AttendantId,VoucherType,CreditDebit,VoucherModeId,VoucherName,ProductVariationId,ProductQuantity,ProductPrice,ProductDiscount,VoucherAmount,VatAmount,CardNumber,RecieptNumber,Createdby,Modifiedby,Datemodified,Datecreated)
			VALUES (source.ShiftId,source.AttendantId,source.VoucherType,source.CreditDebit,source.VoucherModeId,source.VoucherName,source.ProductVariationId,source.ProductQuantity,source.ProductPrice,source.ProductDiscount,source.VoucherAmount,source.VatAmount,source.CardNumber,source.RecieptNumber,source.Createdby,source.Modifiedby,source.DateModified,source.DateCreated);



			 --MERGE INTO ShiftVouchers AS target USING (SELECT ShiftVoucherId,ShiftId,AttendantId,VoucherType,CreditDebit,VoucherModeId,VoucherName,ProductVariationId,ProductQuantity,ProductPrice,ProductDiscount,VoucherAmount,VatAmount,CardNumber,RecieptNumber,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated
			 -- FROM OPENJSON(@JsonObjectdata, '$.ShiftMerchantCollection')
			 -- WITH (ShiftVoucherId BIGINT '$.ShiftVoucherId',ShiftId BIGINT '$.ShiftId',AttendantId BIGINT '$.AttendantId',VoucherType VARCHAR(50) '$.VoucherType',CreditDebit VARCHAR(50) '$.CreditDebit',VoucherModeId BIGINT '$.VoucherModeId',VoucherName VARCHAR(100) '$.VoucherName',ProductVariationId BIGINT '$.ProductVariationId',ProductQuantity DECIMAL(18, 2) '$.ProductQuantity',ProductPrice DECIMAL(18, 2) '$.ProductPrice',ProductDiscount DECIMAL(18, 2) '$.ProductDiscount',VoucherAmount DECIMAL(18, 2) '$.VoucherAmount',VatAmount DECIMAL(18, 2) '$.VatAmount',CardNumber VARCHAR(100) '$.CardNumber',RecieptNumber VARCHAR(100) '$.RecieptNumber',Extra VARCHAR(100) '$.Extra',Extra1 VARCHAR(100) '$.Extra1',Extra2 VARCHAR(100) '$.Extra2',Extra3 VARCHAR(100) '$.Extra3',Extra4 VARCHAR(100) '$.Extra4',Extra5 VARCHAR(100) '$.Extra5',Extra6 VARCHAR(100) '$.Extra6',Extra7 VARCHAR(100) '$.Extra7',Extra8 VARCHAR(100) '$.Extra8',Extra9 VARCHAR(100) '$.Extra9',Extra10 VARCHAR(100) '$.Extra10',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',Datemodified DATETIME '$.DateModified',Datecreated DATETIME '$.DateCreated')
			 -- ) AS source ON target.ShiftVoucherId = source.ShiftVoucherId 
			 -- WHEN MATCHED THEN
			 -- UPDATE SET target.ShiftId = source.ShiftId,target.AttendantId = source.AttendantId,target.VoucherType = source.VoucherType,target.CreditDebit = source.CreditDebit,target.VoucherModeId = source.VoucherModeId,target.VoucherName = source.VoucherName,target.ProductVariationId= source.ProductVariationId,target.ProductQuantity= source.ProductQuantity,target.ProductPrice= source.ProductPrice,target.ProductDiscount= source.ProductDiscount,target.VoucherAmount = source.VoucherAmount,target.VatAmount = source.VatAmount,target.CardNumber = source.CardNumber,target.RecieptNumber = source.RecieptNumber,target.Extra = source.Extra,target.Extra1 = source.Extra1,target.Extra2 = source.Extra2,target.Extra3 = source.Extra3,target.Extra4 = source.Extra4,target.Extra5 = source.Extra5,target.Extra6 = source.Extra6,target.Extra7 = source.Extra7,target.Extra8 = source.Extra8,target.Extra9 = source.Extra9,target.Extra10 = source.Extra10,target.Modifiedby = source.Modifiedby,target.Datemodified = source.Datemodified
			 -- WHEN NOT MATCHED BY TARGET THEN INSERT (ShiftId,AttendantId,VoucherType,CreditDebit,VoucherModeId,VoucherName,ProductVariationId,ProductQuantity,ProductPrice,ProductDiscount,VoucherAmount,VatAmount,CardNumber,RecieptNumber,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated) 
			 -- VALUES (source.ShiftId,source.AttendantId,source.VoucherType,source.CreditDebit,source.VoucherModeId,source.VoucherName,source.ProductVariationId,source.ProductQuantity,source.ProductPrice,source.ProductDiscount,source.VoucherAmount,source.VatAmount,source.CardNumber,source.RecieptNumber,source.Extra,source.Extra1,source.Extra2,source.Extra3,source.Extra4,source.Extra5,source.Extra6,source.Extra7,source.Extra8,source.Extra9,source.Extra10,source.Createdby,source.Modifiedby,source.Datemodified,source.Datecreated);

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