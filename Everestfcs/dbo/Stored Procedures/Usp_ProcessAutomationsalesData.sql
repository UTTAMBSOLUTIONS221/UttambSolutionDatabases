CREATE PROCEDURE [dbo].[Usp_ProcessAutomationsalesData]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @AutomationSaleId BIGINT = 0,
			@TenantId  BIGINT = 0,
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		BEGIN

		  INSERT INTO AutomationSalesData(TenantId,StationId,EfdId,RegId,FdcNum,FdcName,RdgSaveNum,FdcSaveNum,RdgDate,RdgTime,FdcDate,FdcTime,
		  RdgIndex,RdgId,Fp ,PumpAddr,Noz,Price,Vol ,Amo,VolTotal,RoundType,RdgProd ,FdcProd,FdcProdName,FdcTank)
		  (SELECT (SELECT TenantId FROM AutomatedStation WHERE LOWER(Stationcode)= JSON_VALUE(@JsonObjectdata, '$.FtpFolderPath')),(SELECT StationId FROM AutomatedStation WHERE LOWER(Stationcode)= JSON_VALUE(@JsonObjectdata, '$.FtpFolderPath')),JSON_VALUE(@JsonObjectdata, '$.Transaction.EfdId'),JSON_VALUE(@JsonObjectdata, '$.Transaction.RegId'),JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcNum'),JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcName'),JSON_VALUE(@JsonObjectdata, '$.Transaction.RdgSaveNum'),JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcSaveNum'),
		  TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Transaction.RdgDate') AS datetime2(6)),JSON_VALUE(@JsonObjectdata, '$.Transaction.RdgTime'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcDate') AS datetime2(6)),JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcTime'),JSON_VALUE(@JsonObjectdata, '$.Transaction.RdgIndex'),JSON_VALUE(@JsonObjectdata, '$.Transaction.RdgId'),
		  JSON_VALUE(@JsonObjectdata, '$.Transaction.Fp') ,JSON_VALUE(@JsonObjectdata, '$.Transaction.PumpAddr'),JSON_VALUE(@JsonObjectdata, '$.Transaction.Noz'),JSON_VALUE(@JsonObjectdata, '$.Transaction.Price'),JSON_VALUE(@JsonObjectdata, '$.Transaction.Vol') ,JSON_VALUE(@JsonObjectdata, '$.Transaction.Amo'),JSON_VALUE(@JsonObjectdata, '$.Transaction.VolTotal'),
		  JSON_VALUE(@JsonObjectdata, '$.Transaction.RoundType'),JSON_VALUE(@JsonObjectdata, '$.Transaction.RdgProd') ,JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcProd'),JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcProdName'),JSON_VALUE(@JsonObjectdata, '$.Transaction.FdcTank'))
	  
		  SET @AutomationSaleId = SCOPE_IDENTITY();

		  INSERT INTO DiscountSalesData(AutomationSaleId,DiscountType,PriceOrigin,PriceNew,PriceDiscount,VolOrigin,AmoOrigin,AmoNew,AmoDiscount)
		  (SELECT @AutomationSaleId,JSON_VALUE(@JsonObjectdata, '$.Discount.DiscountType'),JSON_VALUE(@JsonObjectdata, '$.Discount.PriceOrigin'),JSON_VALUE(@JsonObjectdata, '$.Discount.PriceNew'),
		  JSON_VALUE(@JsonObjectdata, '$.Discount.PriceDiscount'),JSON_VALUE(@JsonObjectdata, '$.Discount.VolOrigin'),JSON_VALUE(@JsonObjectdata, '$.Discount.AmoOrigin'),JSON_VALUE(@JsonObjectdata, '$.Discount.AmoNew'),JSON_VALUE(@JsonObjectdata, '$.Discount.AmoDiscount'))
	     
		 INSERT INTO RFIDCardSalesData(AutomationSaleId,Used,CardType,Num,Num10,CustName,CustIdType,CustId,CustContact,PayMethod,DiscountType,Discount,ProductEnabled)
		 (SELECT @AutomationSaleId,JSON_VALUE(@JsonObjectdata, '$.RFIDCard.Used'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.CardType'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.Num'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.Num10'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.CustName'),
		 JSON_VALUE(@JsonObjectdata, '$.RFIDCard.CustIdType'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.CustId'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.CustContact'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.PayMethod'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.DiscountType'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.Discount'),JSON_VALUE(@JsonObjectdata, '$.RFIDCard.ProductEnabled'))
		
		Set @RespMsg ='Saved Successfully.'
		Set @RespStat =0; 
		END

		
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