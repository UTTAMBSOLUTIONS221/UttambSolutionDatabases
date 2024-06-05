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
		IF(JSON_VALUE(@JsonObjectdata, '$.StationId')>0)
		BEGIN
		  UPDATE SystemStations SET Sname=JSON_VALUE(@JsonObjectdata, '$.Sname'),Semail=JSON_VALUE(@JsonObjectdata, '$.Semail'),Phone=JSON_VALUE(@JsonObjectdata, '$.Phone'),
		  Addresses=JSON_VALUE(@JsonObjectdata, '$.Addresses'),City=JSON_VALUE(@JsonObjectdata, '$.City'),Street=JSON_VALUE(@JsonObjectdata, '$.Street'),
		  Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE StationId=JSON_VALUE(@JsonObjectdata, '$.StationId')
		  SET @StationId = JSON_VALUE(@JsonObjectdata, '$.StationId');
		END
		ELSE
		BEGIN
		INSERT INTO SystemStations(Tenantid,Sname,Semail,Phone,Addresses,City,Street,CreatedBy,Modifiedby,DateCreated,DateModified)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.Tenantid'),JSON_VALUE(@JsonObjectdata, '$.Sname'),JSON_VALUE(@JsonObjectdata, '$.Semail'),JSON_VALUE(@JsonObjectdata, '$.Phone'),JSON_VALUE(@JsonObjectdata, '$.Addresses'),JSON_VALUE(@JsonObjectdata, '$.City'),
		JSON_VALUE(@JsonObjectdata, '$.Street'),
		JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2))

		SET @StationId = SCOPE_IDENTITY();
		 
		INSERT INTO Stationshifts(StationId,Shiftname,Starttime,Endtime,CreatedBy,ModifiedBy,DateCreated,DateModified)
		SELECT @StationId, Shiftname,Starttime,Endtime,Createdby ,Modifiedby,Datecreated ,Datemodified
		FROM OPENJSON (@JsonObjectdata, '$.StationShifts')
		WITH (
			Shiftname VARCHAR(20),
			Starttime VARCHAR(20),
			Endtime VARCHAR(20),
			Createdby BIGINT,
			Modifiedby BIGINT,
			Datecreated DATETIME,
			Datemodified DATETIME
		)


		END
		

		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,@StationId AS Data1,JSON_VALUE(@JsonObjectdata, '$.Sname') AS Data2;

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