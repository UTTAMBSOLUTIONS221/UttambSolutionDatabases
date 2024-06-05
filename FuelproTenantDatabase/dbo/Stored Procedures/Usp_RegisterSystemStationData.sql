CREATE PROCEDURE [dbo].[Usp_RegisterSystemStationData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@StationId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF EXISTS( SELECT StationId FROM SystemStations WHERE Tenantstationid=CONVERT(bigint,JSON_VALUE(@JsonObjectdata, '$.Data1')))
		BEGIN
		 UPDATE SystemStations SET Sname=JSON_VALUE(@JsonObjectdata, '$.Data2') WHERE Tenantstationid=CONVERT(bigint,JSON_VALUE(@JsonObjectdata, '$.Data1'))
		END
		ELSE
		BEGIN
		INSERT INTO SystemStations(Sname,Tenantstationid)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.Data2'),CONVERT(bigint,JSON_VALUE(@JsonObjectdata, '$.Data1')))
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