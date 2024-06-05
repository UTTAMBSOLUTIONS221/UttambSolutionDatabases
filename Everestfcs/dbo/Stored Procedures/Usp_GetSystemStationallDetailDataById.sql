CREATE PROCEDURE [dbo].[Usp_GetSystemStationallDetailDataById]
@StationId BIGINT,
@StationDetailData NVARCHAR(MAX) OUTPUT
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
		SET @StationDetailData =(
		   SELECT  SS.StationId,SS.Sname,SS.StationId AS Tenantstationid,
			(SELECT aa.Tankid,aa.Stationid,aa.Productvariationid,bb.Productvariationname,aa.Name,aa.Description,aa.Length,aa.Diameter,aa.Volume,
				aa.NumberOfCalibrations,aa.IsActive,aa.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,aa.DateCreated,aa.DateModified
				FROM Stationtanks aa
				INNER JOIN SystemProductvariation bb ON aa.Productvariationid=bb.ProductvariationId
				INNER JOIN SystemStaffs CB ON aa.CreatedBy=CB.UserId
				INNER JOIN SystemStaffs MB ON aa.ModifiedBy=MB.UserId
				WHERE aa.Stationid=SS.StationId
				FOR JSON PATH
				) AS StationTanks,
				(SELECT bb.Pumpid,bb.Stationid,bb.Pumpname,bb.Pumpmodel,bb.Pumpnozzle,bb.IsDoubleSided,
				bb.IsActive,bb.IsDeleted,CB.Firstname+' '+CB.Lastname AS CreatedBy,MB.Firstname+' '+MB.Lastname AS ModifiedBy,bb.DateCreated,bb.DateModified
				FROM Stationpumps bb
				INNER JOIN SystemStaffs CB ON bb.CreatedBy=CB.UserId
				INNER JOIN SystemStaffs MB ON bb.ModifiedBy=MB.UserId
				WHERE bb.Stationid=SS.StationId
				FOR JSON PATH
				) AS StationPumps
		 FROM  SystemStations SS
		 WHERE SS.StationId=@StationId
		 FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
		)
		
		
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@StationDetailData as StationDetailData;

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