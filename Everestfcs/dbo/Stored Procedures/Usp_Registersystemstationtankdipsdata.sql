CREATE PROCEDURE [dbo].[Usp_Registersystemstationtankdipsdata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.StationDipId')=0)
		BEGIN
			INSERT INTO StationDailyDips(StationId,TankId,CurrentDipReading,CurrentMeterReading,PreviousDipReading,PreviousMeterReading,TankVariance,MeterVariance,TankSale,MeterSale,Extra,Extra1,
			Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.StationId'),JSON_VALUE(@JsonObjectdata, '$.TankId'),JSON_VALUE(@JsonObjectdata, '$.CurrentDipReading'),JSON_VALUE(@JsonObjectdata, '$.CurrentMeterReading'),
		JSON_VALUE(@JsonObjectdata, '$.PreviousDipReading'),JSON_VALUE(@JsonObjectdata, '$.PreviousMeterReading'),JSON_VALUE(@JsonObjectdata, '$.TankVariance'),JSON_VALUE(@JsonObjectdata, '$.MeterVariance'),
		JSON_VALUE(@JsonObjectdata, '$.TankSale'),JSON_VALUE(@JsonObjectdata, '$.MeterSale'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),JSON_VALUE(@JsonObjectdata, '$.Extra9'),
		JSON_VALUE(@JsonObjectdata, '$.Extra10'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated')  AS datetime2))
		END
		ELSE
		BEGIN
		UPDATE StationDailyDips SET TankId=JSON_VALUE(@JsonObjectdata, '$.TankId'),CurrentDipReading=JSON_VALUE(@JsonObjectdata, '$.CurrentDipReading'),CurrentMeterReading=JSON_VALUE(@JsonObjectdata, '$.CurrentMeterReading'),PreviousDipReading=JSON_VALUE(@JsonObjectdata, '$.PreviousDipReading'),
		PreviousMeterReading=JSON_VALUE(@JsonObjectdata, '$.PreviousMeterReading'),TankVariance=JSON_VALUE(@JsonObjectdata, '$.TankVariance'),MeterVariance=JSON_VALUE(@JsonObjectdata, '$.MeterVariance'),TankSale=JSON_VALUE(@JsonObjectdata, '$.TankSale'),MeterSale=JSON_VALUE(@JsonObjectdata, '$.MeterSale'),
		Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),
		Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),ModifiedBy=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE StationDipId=JSON_VALUE(@JsonObjectdata, '$.StationDipId')
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