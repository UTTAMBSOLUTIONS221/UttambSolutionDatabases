CREATE PROCEDURE [dbo].[Usp_Registersystemstationpurchasesdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@PurchaseId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.PurchaseId')=0)
		BEGIN
		INSERT INTO StationPurchases (StationId, InvoiceNumber, SupplierId, InvoiceAmount, InvoiceDate,TruckNumber,DriverName, Createdby, Modifiedby, Datemodified, Datecreated)
        VALUES (JSON_VALUE(@JsonObjectdata, '$.StationId'),JSON_VALUE(@JsonObjectdata, '$.InvoiceNumber'),JSON_VALUE(@JsonObjectdata, '$.SupplierId'),
		JSON_VALUE(@JsonObjectdata, '$.InvoiceAmount'),TRY_PARSE(JSON_VALUE(@JsonObjectdata, '$.InvoiceDate') AS DATETIME),JSON_VALUE(@JsonObjectdata, '$.TruckNumber'),JSON_VALUE(@JsonObjectdata, '$.DriverName'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),TRY_PARSE(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS DATETIME),TRY_PARSE(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS DATETIME));

        -- Get the PurchaseId of the inserted record
        SET @PurchaseId = SCOPE_IDENTITY();

        -- Insert into StationPurchaseItems
        INSERT INTO StationPurchaseItems (PurchaseId, ProductVariationId, PurchaseQuantity, PurchasePrice, PurchaseDiscount, PurchaseTotal, Createdby, Modifiedby, Datemodified, Datecreated)
        SELECT @PurchaseId,spi.ProductVariationId,spi.PurchaseQuantity,spi.PurchasePrice,spi.PurchaseDiscount,spi.PurchaseTotal,spi.Createdby,spi.Modifiedby,TRY_PARSE(spi.Datemodified AS DATETIME),TRY_PARSE(spi.Datecreated AS DATETIME)
        FROM OPENJSON(@JsonObjectdata, '$.StationPurchaseItem') WITH ( ProductVariationId BIGINT,PurchaseQuantity DECIMAL(18, 2),PurchasePrice DECIMAL(18, 2),PurchaseDiscount DECIMAL(18, 2),PurchaseTotal DECIMAL(18, 2),Createdby BIGINT, Modifiedby BIGINT, Datemodified NVARCHAR(100),Datecreated NVARCHAR(100)) AS spi;
		END
		ELSE
		BEGIN
		UPDATE StationPurchases SET InvoiceNumber=JSON_VALUE(@JsonObjectdata, '$.InvoiceNumber'),SupplierId=JSON_VALUE(@JsonObjectdata, '$.SupplierId'),InvoiceAmount=JSON_VALUE(@JsonObjectdata, '$.InvoiceAmount'),
		InvoiceDate=CAST(JSON_VALUE(@JsonObjectdata, '$.InvoiceDate')  AS datetime2),Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),
		Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE PurchaseId=JSON_VALUE(@JsonObjectdata, '$.PurchaseId')
	   
	    UPDATE s SET s.PurchaseId=td.PurchaseId, s.ProductVariationId=td.ProductVariationId, s.PurchaseQuantity=td.PurchaseQuantity, s.PurchasePrice=td.PurchasePrice, s.PurchaseDiscount=td.PurchaseDiscount, s.PurchaseTotal=td.PurchaseTotal, s.Createdby=td.Createdby, s.Modifiedby=td.Modifiedby, s.Datemodified=td.Datemodified, s.Datecreated=td.Datecreated FROM StationPurchaseItems s JOIN OPENJSON(@JsonObjectdata, '$.StationPurchaseItem')
        WITH (PurchaseId BIGINT '$.PurchaseId', ProductVariationId BIGINT '$.ProductVariationId', PurchaseQuantity DECIMAL(18, 2) '$.PurchaseQuantity', PurchasePrice DECIMAL(18, 2) '$.PurchasePrice', PurchaseDiscount DECIMAL(18, 2) '$.PurchaseDiscount', PurchaseTotal DECIMAL(18, 2) '$.PurchaseTotal', Createdby BIGINT '$.Createdby', Modifiedby BIGINT '$.Modifiedby', Datemodified DATETIME '$.Datemodified', Datecreated DATETIME '$.Datecreated'
        ) AS td ON s.PurchaseId = td.PurchaseId;

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