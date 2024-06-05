CREATE PROCEDURE [dbo].[Usp_Registersystemstationshiftdrystockpurchasedata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@DrystockPurchaseId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		BEGIN
			DECLARE @DrystockPurchase TABLE (PurchaseId BIGINT)
			-- Merge for the purchase
			  MERGE INTO ShiftPurchases AS target USING (SELECT PurchaseId,ShiftId,WetDryPurchase,InvoiceNumber,SupplierId,InvoiceAmount,TransportAmount,InvoiceDate,TruckNumber,DriverName,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated
			  FROM OPENJSON(@JsonObjectdata)
			  WITH (PurchaseId BIGINT '$.PurchaseId',ShiftId BIGINT '$.ShiftId',WetDryPurchase VARCHAR(100) '$.WetDryPurchase',InvoiceNumber VARCHAR(100) '$.InvoiceNumber',SupplierId BIGINT '$.SupplierId',InvoiceAmount DECIMAL(18, 2) '$.InvoiceAmount',TransportAmount DECIMAL(18, 2) '$.TransportAmount',InvoiceDate DATETIME '$.InvoiceDate',TruckNumber VARCHAR(100) '$.TruckNumber',DriverName VARCHAR(100) '$.DriverName',Extra VARCHAR(100) '$.Extra',Extra1 VARCHAR(100) '$.Extra1',Extra2 VARCHAR(100) '$.Extra2',Extra3 VARCHAR(100) '$.Extra3',Extra4 VARCHAR(100) '$.Extra4',Extra5 VARCHAR(100) '$.Extra5',Extra6 VARCHAR(100) '$.Extra6',Extra7 VARCHAR(100) '$.Extra7',Extra8 VARCHAR(100) '$.Extra8',Extra9 VARCHAR(100) '$.Extra9',Extra10 VARCHAR(100) '$.Extra10',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',DateCreated DATETIME '$.DateCreated',DateModified DATETIME '$.DateModified')
			  ) AS source ON target.PurchaseId = source.PurchaseId 
			  WHEN MATCHED THEN
			  UPDATE SET target.ShiftId = source.ShiftId,target.WetDryPurchase = source.WetDryPurchase,target.InvoiceNumber = source.InvoiceNumber,target.SupplierId = source.SupplierId,target.InvoiceAmount = source.InvoiceAmount,target.TransportAmount = source.TransportAmount,target.InvoiceDate = source.InvoiceDate,target.TruckNumber = source.TruckNumber,target.DriverName = source.DriverName,target.Extra = source.Extra,target.Extra1 = source.Extra1,target.Extra2 = source.Extra2,target.Extra3 = source.Extra3,target.Extra4 = source.Extra4,target.Extra5 = source.Extra5,target.Extra6 = source.Extra6,target.Extra7 = source.Extra7,target.Extra8 = source.Extra8,target.Extra9 = source.Extra9,target.Extra10 = source.Extra10,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
			  WHEN NOT MATCHED THEN
			  INSERT (ShiftId,WetDryPurchase,InvoiceNumber,SupplierId,InvoiceAmount,TransportAmount,InvoiceDate,TruckNumber,DriverName,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,DateModified,DateCreated)
			  VALUES (source.ShiftId,source.WetDryPurchase,source.InvoiceNumber,source.SupplierId,source.InvoiceAmount,source.TransportAmount,source.InvoiceDate,source.TruckNumber,source.DriverName,source.Extra,source.Extra1,source.Extra2,source.Extra3,source.Extra4,source.Extra5,source.Extra6,source.Extra7,source.Extra8,source.Extra9,source.Extra10,source.Createdby,source.Modifiedby,source.DateModified,source.DateCreated)
              OUTPUT inserted.PurchaseId INTO @DrystockPurchase;
			  SET @DrystockPurchaseId = (SELECT PurchaseId FROM @DrystockPurchase);

			-- Merge for the purchase items
			MERGE INTO ShiftPurchasesItems AS target USING (SELECT PurchaseItemId,PurchaseId,ProductVariationId,TankId,DipsBeforeOffloading,PurchaseQuantity,DipsAfterOffloading,ExpectedQuantity,Gainloss,PercentGainloss,PurchasePrice,PurchaseTax,PurchaseDiscount,PurchaseGTotal,PurchaseNTotal,PurchaseTaxAmount,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated
			FROM OPENJSON(@JsonObjectdata) 
			WITH (PurchaseItemId BIGINT '$.PurchaseItemId',PurchaseId BIGINT '$.PurchaseId',ProductVariationId BIGINT '$.ProductVariationId',TankId BIGINT '$.TankId',DipsBeforeOffloading DECIMAL(18,2) '$.DipsBeforeOffloading',PurchaseQuantity DECIMAL(18,2) '$.PurchaseQuantity',DipsAfterOffloading DECIMAL(18,2) '$.DipsAfterOffloading',ExpectedQuantity DECIMAL(18,2) '$.ExpectedQuantity',Gainloss DECIMAL(18,2) '$.Gainloss',PercentGainloss DECIMAL(18,2) '$.PercentGainloss',PurchasePrice DECIMAL(18,2) '$.PurchasePrice',PurchaseTax DECIMAL(18,2) '$.PurchaseTax',PurchaseDiscount DECIMAL(18,2) '$.PurchaseDiscount',PurchaseGTotal DECIMAL(18,2) '$.PurchaseGTotal',PurchaseNTotal DECIMAL(18,2) '$.PurchaseNTotal',PurchaseTaxAmount DECIMAL(18,2) '$.PurchaseTaxAmount',Extra VARCHAR(100) '$.Extra',Extra1 VARCHAR(100) '$.Extra1',Extra2 VARCHAR(100) '$.Extra2',Extra3 VARCHAR(100) '$.Extra3',Extra4 VARCHAR(100) '$.Extra4',Extra5 VARCHAR(100) '$.Extra5',Extra6 VARCHAR(100) '$.Extra6',Extra7 VARCHAR(100) '$.Extra7',Extra8 VARCHAR(100) '$.Extra8',Extra9 VARCHAR(100) '$.Extra9',Extra10 VARCHAR(100) '$.Extra10',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',DateCreated DATETIME '$.DateCreated',DateModified DATETIME '$.DateModified')
			) AS source ON target.PurchaseItemId = source.PurchaseItemId -- Assuming ItemId is the unique identifier
			WHEN MATCHED THEN 
			UPDATE SET target.ProductVariationId = source.ProductVariationId,target.TankId = source.TankId,target.DipsBeforeOffloading=source.DipsBeforeOffloading,target.PurchaseQuantity=source.PurchaseQuantity,target.DipsAfterOffloading=source.DipsAfterOffloading,target.ExpectedQuantity=source.ExpectedQuantity,target.Gainloss=source.Gainloss,target.PercentGainloss=source.PercentGainloss,target.PurchasePrice=source.PurchasePrice,target.PurchaseTax=source.PurchaseTax,target.PurchaseDiscount=source.PurchaseDiscount,target.PurchaseGTotal=source.PurchaseGTotal,target.PurchaseNTotal=source.PurchaseNTotal,target.PurchaseTaxAmount=source.PurchaseTaxAmount,target.Extra = source.Extra,target.Extra1 = source.Extra1,target.Extra2 = source.Extra2,target.Extra3 = source.Extra3,target.Extra4 = source.Extra4,target.Extra5 = source.Extra5,target.Extra6 = source.Extra6,target.Extra7 = source.Extra7,target.Extra8 = source.Extra8,target.Extra9 = source.Extra9,target.Extra10 = source.Extra10,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
			WHEN NOT MATCHED THEN
			INSERT (PurchaseId,ProductVariationId,TankId,DipsBeforeOffloading,PurchaseQuantity,DipsAfterOffloading,ExpectedQuantity,Gainloss,PercentGainloss,PurchasePrice,PurchaseTax,PurchaseDiscount,PurchaseGTotal,PurchaseNTotal,PurchaseTaxAmount,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated)
			VALUES (@DrystockPurchaseId,source.ProductVariationId,source.TankId,source.DipsBeforeOffloading,source.PurchaseQuantity,source.DipsAfterOffloading,source.ExpectedQuantity,source.Gainloss,source.PercentGainloss,source.PurchasePrice,source.PurchaseTax,source.PurchaseDiscount,source.PurchaseGTotal,source.PurchaseNTotal,source.PurchaseTaxAmount,source.Extra,source.Extra1,source.Extra2,source.Extra3,source.Extra4,source.Extra5,source.Extra6,source.Extra7,source.Extra8,source.Extra9,source.Extra10,source.Createdby,source.Modifiedby,source.Datemodified,source.Datecreated);
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