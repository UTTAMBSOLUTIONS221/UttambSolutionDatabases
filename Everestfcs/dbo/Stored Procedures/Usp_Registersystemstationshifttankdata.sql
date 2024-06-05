CREATE PROCEDURE [dbo].[Usp_Registersystemstationshifttankdata]
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
			MERGE INTO ShiftsTankReadings AS target
			USING (
			SELECT ShiftTankReadingId,ShiftId,TankId,AttendantId,ProductPrice,OpeningQuantity,ClosingQuantity,QuantitySold,AmountSold,Createdby,Modifiedby,DateModified,DateCreated
			FROM OPENJSON(@JsonObjectdata, '$.ShiftTankReading')
			WITH (ShiftTankReadingId BIGINT '$.ShiftTankReadingId',ShiftId BIGINT '$.ShiftId',TankId BIGINT '$.TankId',AttendantId BIGINT '$.AttendantId',ProductPrice DECIMAL(18,2) '$.ProductPrice',OpeningQuantity DECIMAL(18,2) '$.OpeningQuantity',ClosingQuantity DECIMAL(18,2) '$.ClosingQuantity',QuantitySold DECIMAL(18,2) '$.QuantitySold',AmountSold DECIMAL(18,2) '$.AmountSold',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',DateModified DATETIME '$.DateModified',DateCreated DATETIME '$.DateCreated'
			)) AS source
			ON target.ShiftTankReadingId = source.ShiftTankReadingId
			WHEN MATCHED THEN
			UPDATE SET target.ShiftId = source.ShiftId,target.TankId = source.TankId,target.AttendantId = source.AttendantId,target.ProductPrice = source.ProductPrice,target.OpeningQuantity = source.OpeningQuantity,target.ClosingQuantity = source.ClosingQuantity,target.QuantitySold = source.QuantitySold,target.AmountSold = source.AmountSold,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
			WHEN NOT MATCHED THEN
			INSERT (ShiftId,TankId,AttendantId,ProductPrice,OpeningQuantity,ClosingQuantity,QuantitySold,AmountSold,Createdby,Modifiedby,DateModified,DateCreated)
			VALUES (@ShiftId,source.TankId,source.AttendantId,source.ProductPrice,source.OpeningQuantity,source.ClosingQuantity,source.QuantitySold,source.AmountSold,source.Createdby,source.Modifiedby,source.DateModified,source.DateCreated);
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