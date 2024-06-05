CREATE PROCEDURE [dbo].[Usp_RegisterSystemStaffData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@UserId BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		IF EXISTS(SELECT StaffId FROM SystemStaffs WHERE UserId=JSON_VALUE(@JsonObjectdata, '$.Data1'))
		BEGIN
		 UPDATE SystemStaffs SET Fullname=JSON_VALUE(@JsonObjectdata, '$.Data2')  WHERE UserId=JSON_VALUE(@JsonObjectdata, '$.Data1')

		  DELETE FROM LnkStaffStation WHERE UserId = JSON_VALUE(@JsonObjectdata, '$.Data1') AND StationId NOT IN (SELECT StationId FROM OPENJSON(JSON_VALUE(@JsonObjectdata, '$.Data9')) WITH (StationId INT '$.StationId'));

		 INSERT INTO LnkStaffStation (UserId, StationId)SELECT JSON_VALUE(@JsonObjectdata, '$.Data1'), StationId
         FROM OPENJSON(JSON_VALUE(@JsonObjectdata, '$.Data9')) WITH (StationId INT '$.StationId') AS jsonStations WHERE NOT EXISTS (SELECT 1 FROM LnkStaffStation WHERE UserId = JSON_VALUE(@JsonObjectdata, '$.Data1'));
		END
		ELSE
		BEGIN
			INSERT INTO SystemStaffs(Fullname,UserId)(SELECT JSON_VALUE(@JsonObjectdata, '$.Data2'),JSON_VALUE(@JsonObjectdata, '$.Data1'))
			
			DELETE FROM LnkStaffStation WHERE UserId = JSON_VALUE(@JsonObjectdata, '$.Data1') AND StationId NOT IN (SELECT StationId FROM OPENJSON(JSON_VALUE(@JsonObjectdata, '$.Data9')) WITH (StationId INT '$.StationId'));

			INSERT INTO LnkStaffStation (UserId, StationId)SELECT JSON_VALUE(@JsonObjectdata, '$.Data1'), StationId
            FROM OPENJSON(JSON_VALUE(@JsonObjectdata, '$.Data9')) WITH (StationId INT '$.StationId') AS jsonStations WHERE NOT EXISTS (SELECT 1 FROM LnkStaffStation WHERE UserId = JSON_VALUE(@JsonObjectdata, '$.Data1'));
		END

		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		 Select @RespStat as RespStatus, @RespMsg as RespMessage,JSON_VALUE(@JsonObjectdata, '$.Data1') AS Data1,JSON_VALUE(@JsonObjectdata, '$.Data2') AS Data2,JSON_VALUE(@JsonObjectdata, '$.Data3') AS Data3,JSON_VALUE(@JsonObjectdata, '$.Data4') AS Data4,JSON_VALUE(@JsonObjectdata, '$.Data5') AS Data5,JSON_VALUE(@JsonObjectdata, '$.Data6') AS Data6,JSON_VALUE(@JsonObjectdata, '$.Data7') AS Data7;
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