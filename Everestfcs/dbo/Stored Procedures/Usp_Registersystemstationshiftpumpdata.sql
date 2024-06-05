CREATE PROCEDURE [dbo].[Usp_Registersystemstationshiftpumpdata]
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
		SET @ShiftId =(SELECT ShiftId FROM OPENJSON(@JsonObjectdata) WITH (ShiftId BIGINT '$.ShiftId'));
		MERGE INTO ShiftsPumpReadings AS target 
		USING (
		SELECT ShiftPumpReadingId,ShiftId,PumpId,NozzleId,AttendantId,ProductPrice,OpeningShilling,ClosingShilling,TotalShilling,
		ShillingDifference,OpeningElectronic,ClosingElectronic,ElectronicSold,ElectronicAmount,OpeningManual,
		ClosingManual,TestingRtt,ManualSold,ManualAmount,LitersDifference,PumpRttAmount,TotalPumpAmount,Modifiedby,DateModified
		FROM OPENJSON(@JsonObjectdata, '$.ShiftPumpReading')
		WITH (ShiftPumpReadingId BIGINT '$.ShiftPumpReadingId',ShiftId BIGINT '$.ShiftId',PumpId BIGINT '$.PumpId',NozzleId BIGINT '$.NozzleId',AttendantId BIGINT '$.AttendantId',ProductPrice DECIMAL(18,2) '$.ProductPrice',OpeningShilling DECIMAL(18,2) '$.OpeningShilling',ClosingShilling DECIMAL(18,2) '$.ClosingShilling',TotalShilling DECIMAL(18,2) '$.TotalShilling',ShillingDifference DECIMAL(18,2) '$.ShillingDifference',
		OpeningElectronic DECIMAL(18,2) '$.OpeningElectronic',ClosingElectronic DECIMAL(18,2) '$.ClosingElectronic',ElectronicSold DECIMAL(18,2) '$.ElectronicSold',ElectronicAmount DECIMAL(18,2) '$.ElectronicAmount',OpeningManual DECIMAL(18,2) '$.OpeningManual',ClosingManual DECIMAL(18,2) '$.ClosingManual',TestingRtt DECIMAL(18,2) '$.TestingRtt',ManualSold DECIMAL(18,2) '$.ManualSold',ManualAmount DECIMAL(18,2) '$.ManualAmount',
		LitersDifference DECIMAL(18,2) '$.LitersDifference',PumpRttAmount DECIMAL(18,2) '$.PumpRttAmount',TotalPumpAmount DECIMAL(18,2) '$.TotalPumpAmount',Modifiedby BIGINT '$.Modifiedby',DateModified DATETIME '$.DateModified')
	   ) AS source ON target.ShiftPumpReadingId = source.ShiftPumpReadingId
      WHEN MATCHED THEN
      UPDATE SET target.ShiftId = source.ShiftId,target.ProductPrice = source.ProductPrice,target.OpeningShilling = source.OpeningShilling,target.ClosingShilling = source.ClosingShilling,
        target.TotalShilling = source.TotalShilling,target.ShillingDifference = source.ShillingDifference,target.OpeningElectronic = source.OpeningElectronic,target.ClosingElectronic = source.ClosingElectronic,
        target.ElectronicSold = source.ElectronicSold,target.ElectronicAmount = source.ElectronicAmount,target.OpeningManual = source.OpeningManual,target.ClosingManual = source.ClosingManual,target.TestingRtt = source.TestingRtt,target.ManualSold = source.ManualSold,
        target.ManualAmount = source.ManualAmount,target.LitersDifference = source.LitersDifference,target.PumpRttAmount = source.PumpRttAmount,target.TotalPumpAmount = source.TotalPumpAmount,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
     WHEN NOT MATCHED THEN
     INSERT (ShiftId,PumpId,NozzleId,AttendantId,ProductPrice,OpeningShilling,ClosingShilling,TotalShilling,ShillingDifference,OpeningElectronic,ClosingElectronic,ElectronicSold,ElectronicAmount,OpeningManual,ClosingManual,TestingRtt,ManualSold,ManualAmount,LitersDifference,PumpRttAmount,TotalPumpAmount,Createdby,Modifiedby,DateModified,DateCreated)
     VALUES (@ShiftId,source.PumpId,source.NozzleId,source.AttendantId,source.ProductPrice,source.OpeningShilling,source.ClosingShilling,source.TotalShilling,source.ShillingDifference,source.OpeningElectronic,source.ClosingElectronic,source.ElectronicSold,source.ElectronicAmount,source.OpeningManual,source.ClosingManual,source.TestingRtt,source.ManualSold,source.ManualAmount,source.LitersDifference,source.PumpRttAmount,source.TotalPumpAmount,source.Modifiedby,source.Modifiedby,source.DateModified,source.DateModified);
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