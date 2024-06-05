CREATE PROCEDURE [dbo].[Usp_GetSystemStationDetailDataById]
	@StationId BIGINT,
	@StationDetailData VARCHAR(MAX) OUTPUT
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
	       SELECT a.StationId,a.Tenantid,a.Sname,a.Semail,a.Phone,a.Addresses,a.City,a.Street,a.IsDefault,a.IsActive,a.IsDeleted,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Createdby,a.Modifiedby,a.DateCreated,a.DateModified,
		  ( 
		    SELECT aa.ShiftId,aa.StationId,aa.Shiftname,aa.Starttime,aa.Endtime,aa.Isactive,aa.Isdeleted,aa.Createdby,aa.Modifiedby,aa.Datecreated,aa.Datemodified FROM Stationshifts aa WHERE aa.StationId=a.StationId FOR JSON PATH ) AS StationShifts
            FROM SystemStations a WHERE a.StationId=@StationId
		    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
		  )

	
		
	
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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