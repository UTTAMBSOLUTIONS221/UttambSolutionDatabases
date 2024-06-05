CREATE PROCEDURE [dbo].[Usp_Getsystemstationshiftlistdata]
	@StationId BIGINT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		BEGIN TRANSACTION;
		SELECT a.ShiftId,a.StationId,b.Sname AS StationName,a.ShiftCode,a.ShiftCategory,a.CashOrAccount,a.ShiftDateTime,a.ShiftStatus,a.ShiftTotalAmount
      ,a.ShiftBankedAmount
      ,a.ShiftBalance
      ,a.ExpectedTankAmount
      ,a.ExpectedPumpAmount,a.GainLoss
      ,a.PercentGainLoss
      ,a.ShiftBankReference
      ,a.ShiftReference,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Createdby,a.Modifiedby,a.Datemodified,a.Datecreated 
		FROM Stationshifts a
		INNER JOIN SystemStations b ON a.StationId=b.StationId
		WHERE (a.StationId=@StationId OR 0=@StationId)
		ORDER BY a.Datecreated DESC
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage;

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