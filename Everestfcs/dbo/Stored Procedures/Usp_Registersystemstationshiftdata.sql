
CREATE PROCEDURE [dbo].[Usp_Registersystemstationshiftdata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.ShiftId')=0)
		BEGIN
		INSERT INTO Stationshifts(StationId,ShiftCode,ShiftCategory,CashOrAccount,ShiftDateTime,ShiftStatus,ShiftTotalAmount,ShiftBankedAmount,ShiftBalance,ExpectedTankAmount,ExpectedPumpAmount,GainLoss,PercentGainLoss,
		Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Createdby,Modifiedby,Datemodified,Datecreated)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.StationId'),JSON_VALUE(@JsonObjectdata, '$.ShiftCode'),JSON_VALUE(@JsonObjectdata, '$.ShiftCategory'),JSON_VALUE(@JsonObjectdata, '$.CashOrAccount'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.ShiftDateTime')  AS datetime2),0,JSON_VALUE(@JsonObjectdata, '$.ShiftTotalAmount'),JSON_VALUE(@JsonObjectdata, '$.ShiftBankedAmount'),JSON_VALUE(@JsonObjectdata, '$.ShiftBalance'),JSON_VALUE(@JsonObjectdata, '$.ExpectedTankAmount'),
		JSON_VALUE(@JsonObjectdata, '$.ExpectedPumpAmount'),JSON_VALUE(@JsonObjectdata, '$.GainLoss'),JSON_VALUE(@JsonObjectdata, '$.PercentGainLoss'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),JSON_VALUE(@JsonObjectdata, '$.Extra9'),
		JSON_VALUE(@JsonObjectdata, '$.Extra10'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated')  AS datetime2))

		SET @ShiftId = SCOPE_IDENTITY();
		END
		ELSE
		BEGIN
		    UPDATE Stationshifts SET ShiftCategory=JSON_VALUE(@JsonObjectdata, '$.ShiftCategory'),ShiftDateTime=CAST(JSON_VALUE(@JsonObjectdata, '$.ShiftDateTime')  AS datetime2),ShiftTotalAmount=JSON_VALUE(@JsonObjectdata, '$.ShiftTotalAmount'),ShiftBankedAmount=JSON_VALUE(@JsonObjectdata, '$.ShiftBankedAmount'),ShiftBalance=JSON_VALUE(@JsonObjectdata, '$.ShiftBalance'),ExpectedTankAmount=JSON_VALUE(@JsonObjectdata, '$.ExpectedTankAmount'),
		    ExpectedPumpAmount=JSON_VALUE(@JsonObjectdata, '$.ExpectedPumpAmount'),GainLoss=JSON_VALUE(@JsonObjectdata, '$.GainLoss'),PercentGainLoss=JSON_VALUE(@JsonObjectdata, '$.PercentGainLoss'),ShiftBankReference=JSON_VALUE(@JsonObjectdata, '$.ShiftBankReference'),ShiftReference=JSON_VALUE(@JsonObjectdata, '$.ShiftReference'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2) WHERE ShiftId=JSON_VALUE(@JsonObjectdata, '$.ShiftId')
		  SET @ShiftId = JSON_VALUE(@JsonObjectdata, '$.ShiftId');
		END
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage, @ShiftId AS Data1;

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