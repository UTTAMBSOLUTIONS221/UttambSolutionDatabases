CREATE PROCEDURE [dbo].[Usp_Getsystemstationshiftdetaildata]
	@Stationshiftdetaildata VARCHAR(MAX)  OUTPUT
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
		  SET @Stationshiftdetaildata = (
			  SELECT (SELECT aaa.ShiftId,aaa.StationId,aaa.ShiftCode,aaa.ShiftCategory,aaa.ShiftDateTime,0 AS TotalCustomerinvoices,aaa.ShiftStatus,
				aaa.Extra,aaa.Extra1,aaa.Extra2,aaa.Extra3,aaa.Extra4,aaa.Extra5,aaa.Extra6,aaa.Extra7,aaa.Extra8,
				aaa.Extra9,aaa.Extra10,aaa.Createdby,aaa.Modifiedby,aaa.Datemodified,aaa.Datecreated,
				(SELECT a.ShiftDataId,a.ShiftId,aa.ShiftCode,aa.ShiftCategory,aa.ShiftDateTime,a.AttendantId,
				b.Firstname+' '+b.Lastname AS AttendantName,a.PumpId,c.Pumpname,a.OpeningRead AS OpeningMeter,a.ClosingRead AS ClosingMeter,CASE WHEN a.ClosingRead=0 THEN a.ClosingRead ELSE a.ClosingRead-a.OpeningRead END AS MovedMeter,a.Extra,a.Extra1,a.Extra2,a.Extra3,
				a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Createdby,a.Modifiedby,a.Datemodified,a.Datecreated
				  FROM StationshiftsData a
				  INNER JOIN Stationshifts aa ON a.ShiftId=aa.ShiftId
				  INNER JOIN SystemStaffs b ON a.AttendantId=b.Userid
				  INNER JOIN Stationpumps c ON a.PumpId=c.Pumpid
				  WHERE a.ShiftId=aaa.ShiftId
				  FOR JSON PATH
				  ) AS StationShiftData
				FROM Stationshifts aaa
				 FOR JSON PATH
				) AS StationShifts
				FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
			  )
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
           SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@Stationshiftdetaildata AS Stationshiftdetaildata  
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