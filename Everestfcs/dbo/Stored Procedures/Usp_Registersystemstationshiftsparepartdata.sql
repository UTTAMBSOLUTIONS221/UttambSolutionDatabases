CREATE PROCEDURE [dbo].[Usp_Registersystemstationshiftsparepartdata]
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
			MERGE INTO ShiftLubeandLpg AS target
			USING (SELECT ShiftLubeLpgId,ShiftId,StockTypeId,AttendantId,ProductVariationId,OpeningUnits,ClosingUnits,UnitsSold,ProductPrice,UnitsTotal,Createdby,Modifiedby,DateCreated,DateModified
			FROM OPENJSON(@JsonObjectdata, '$.ShiftLpgReading')
			WITH (ShiftLubeLpgId BIGINT '$.ShiftLubeLpgId',ShiftId BIGINT '$.ShiftId',StockTypeId BIGINT '$.StockTypeId',AttendantId BIGINT '$.AttendantId',ProductVariationId BIGINT '$.ProductVariationId',OpeningUnits DECIMAL(18,2) '$.OpeningUnits',ClosingUnits DECIMAL(18,2) '$.ClosingUnits',UnitsSold DECIMAL(18,2) '$.UnitsSold',ProductPrice DECIMAL(18,2) '$.ProductPrice',UnitsTotal DECIMAL(18,2) '$.UnitsTotal',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',DateModified DATETIME '$.DateModified',DateCreated DATETIME '$.DateCreated'
			)) AS source
			ON target.ShiftLubeLpgId = source.ShiftLubeLpgId
			WHEN MATCHED  AND source.ShiftLubeLpgId <> 0 THEN
			UPDATE SET target.ShiftId = source.ShiftId,target.StockTypeId = source.StockTypeId,target.AttendantId = source.AttendantId,target.ProductVariationId = source.ProductVariationId,target.OpeningUnits = source.OpeningUnits,target.ClosingUnits = source.ClosingUnits,target.UnitsSold = source.UnitsSold,target.ProductPrice = source.ProductPrice,target.UnitsTotal = source.UnitsTotal,target.Modifiedby = source.Modifiedby,target.DateModified = source.DateModified
			WHEN NOT MATCHED THEN
			INSERT (ShiftId,StockTypeId,AttendantId,ProductVariationId,OpeningUnits,ClosingUnits,UnitsSold,ProductPrice,UnitsTotal,Createdby,Modifiedby,DateModified,DateCreated)
			VALUES (@ShiftId,source.StockTypeId,source.AttendantId,source.ProductVariationId,source.OpeningUnits,source.ClosingUnits,source.UnitsSold,source.ProductPrice,source.UnitsTotal,source.Createdby,source.Modifiedby,source.DateModified,source.DateCreated);
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