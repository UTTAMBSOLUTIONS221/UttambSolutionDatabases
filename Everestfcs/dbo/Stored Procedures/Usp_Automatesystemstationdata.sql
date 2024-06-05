CREATE PROCEDURE [dbo].[Usp_Automatesystemstationdata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @AutomatedStationId BIGINT = 0,
			@Stationcode VARCHAR(50),
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		BEGIN	
		IF EXISTS(SELECT AutomatedStationId FROM AutomatedStation WHERE TenantId= JSON_VALUE(@JsonObjectdata, '$.TenantId') AND StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') AND  Isautomated=1)
		BEGIN
		  UPDATE SystemStations SET Extra=0 WHERE StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') AND TenantId= JSON_VALUE(@JsonObjectdata, '$.TenantId');
		  UPDATE AutomatedStation SET Isautomated=0 WHERE StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') AND TenantId= JSON_VALUE(@JsonObjectdata, '$.TenantId');
		 Set @RespMsg ='Station Switched to Manual.'
		Set @RespStat =0; 
		END
		ELSE IF EXISTS(SELECT AutomatedStationId FROM AutomatedStation WHERE TenantId= JSON_VALUE(@JsonObjectdata, '$.TenantId') AND StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') AND  Isautomated=0)
		BEGIN
		  UPDATE SystemStations SET Extra=1 WHERE StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') AND TenantId= JSON_VALUE(@JsonObjectdata, '$.TenantId');
		  UPDATE AutomatedStation SET Isautomated=1 WHERE StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') AND TenantId= JSON_VALUE(@JsonObjectdata, '$.TenantId');
		 Set @RespMsg ='Station Switched to Manual.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		  INSERT INTO AutomatedStation(TenantId,StationId,Stationcode,Isautomated,Automatedby,DateAutomated)
		  (SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'),JSON_VALUE(@JsonObjectdata, '$.StationId'),'OUT'+dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID),
		  JSON_VALUE(@JsonObjectdata, '$.Isautomated'),JSON_VALUE(@JsonObjectdata, '$.Automatedby'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.DateAutomated') AS datetime2(6)))
	  
		  SET @AutomatedStationId = SCOPE_IDENTITY();
		  UPDATE SystemStations SET Extra=1 WHERE StationId=JSON_VALUE(@JsonObjectdata, '$.StationId');
		  SELECT @Stationcode=Stationcode FROM AutomatedStation WHERE @AutomatedStationId=AutomatedStationId;
		  Set @RespMsg ='Station Automated.'
		  Set @RespStat =0; 
		END
		END
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,@Stationcode AS Data1;

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