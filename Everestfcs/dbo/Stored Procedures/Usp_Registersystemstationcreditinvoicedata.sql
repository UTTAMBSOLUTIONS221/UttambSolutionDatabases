CREATE PROCEDURE [dbo].[Usp_Registersystemstationcreditinvoicedata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@ShiftId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.ShiftCreditInvoiceId')=0)
		BEGIN
			INSERT INTO ShiftCreditInvoices(ShiftId,AttendantId,CustomerId,EquipmentId,ProductVariationId,ProductUnits,ProductPrice,ProductDiscount,ProductTotal,Extra,Extra1,
			Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.ShiftId'),JSON_VALUE(@JsonObjectdata, '$.AttendantId'),JSON_VALUE(@JsonObjectdata, '$.CustomerId'),JSON_VALUE(@JsonObjectdata, '$.EquipmentId'),
		JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),JSON_VALUE(@JsonObjectdata, '$.ProductUnits'),JSON_VALUE(@JsonObjectdata, '$.ProductPrice'),JSON_VALUE(@JsonObjectdata, '$.ProductDiscount'),
		JSON_VALUE(@JsonObjectdata, '$.ProductTotal'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),JSON_VALUE(@JsonObjectdata, '$.Extra9'),
		JSON_VALUE(@JsonObjectdata, '$.Extra10'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated')  AS datetime2))
		END
		ELSE
		BEGIN
		UPDATE ShiftCreditInvoices SET CustomerId=JSON_VALUE(@JsonObjectdata, '$.CustomerId'),EquipmentId=JSON_VALUE(@JsonObjectdata, '$.EquipmentId'),
		ProductVariationId=JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),ProductUnits=JSON_VALUE(@JsonObjectdata, '$.ProductUnits'),ProductPrice=JSON_VALUE(@JsonObjectdata, '$.ProductPrice'),ProductDiscount=JSON_VALUE(@JsonObjectdata, '$.ProductDiscount'),
		ProductTotal=JSON_VALUE(@JsonObjectdata, '$.ProductTotal'),Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),
		Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),ModifiedBy=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE ShiftCreditInvoiceId=JSON_VALUE(@JsonObjectdata, '$.ShiftCreditInvoiceId')
			END
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