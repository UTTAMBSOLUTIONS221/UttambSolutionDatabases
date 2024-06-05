CREATE PROCEDURE [dbo].[Usp_Getsystempumpdatabyid]
	@PumpId BIGINT,
	@StationPumpDetails NVARCHAR(MAX) OUTPUT
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
		SET @StationPumpDetails=(
		 SELECT SP.Pumpid,SP.Stationid,SP.Tankid,SP.Pumpname,SP.Pumpmodel,SP.Pumpnozzle,SP.IsDoubleSided,SP.IsActive,SP.IsDeleted,SP.CreatedBy,SP.ModifiedBy,SP.DateCreated,SP.DateModified,
		  (SELECT PN.Nozzleid,PN.Tankid,ST.Name AS TankName,PN.Pumpid,PN.Side,PN.Nozzle FROM PumpNozzles PN  INNER JOIN Stationtanks ST ON PN.Tankid=ST.Tankid WHERE SP.Pumpid=PN.Pumpid FOR JSON PATH) AS StationPumpNozzles
		  FROM Stationpumps SP WHERE  SP.Pumpid=@PumpId
		 FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		 )
		  Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@StationPumpDetails as StationPumpDetails;;

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
