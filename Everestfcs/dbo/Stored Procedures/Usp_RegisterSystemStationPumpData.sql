CREATE PROCEDURE [dbo].[Usp_RegisterSystemStationPumpData]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Pumpid BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		BEGIN
				DECLARE @Pumpdata TABLE (PumpId BIGINT)
				-- Merge for the Pumps
				MERGE INTO Stationpumps AS target
				USING (SELECT JSON_VALUE(@JsonObjectdata, '$.Pumpid') AS Pumpid,JSON_VALUE(@JsonObjectdata, '$.Stationid') AS Stationid,JSON_VALUE(@JsonObjectdata, '$.Tankid') AS Tankid,JSON_VALUE(@JsonObjectdata, '$.Pumpname') AS Pumpname,JSON_VALUE(@JsonObjectdata, '$.Pumpmodel') AS Pumpmodel,JSON_VALUE(@JsonObjectdata, '$.Pumpnozzle') AS Pumpnozzle,JSON_VALUE(@JsonObjectdata, '$.IsDoubleSided') AS IsDoubleSided,JSON_VALUE(@JsonObjectdata, '$.IsActive') AS IsActive,JSON_VALUE(@JsonObjectdata, '$.IsDeleted') AS IsDeleted,JSON_VALUE(@JsonObjectdata, '$.CreatedBy') AS CreatedBy,JSON_VALUE(@JsonObjectdata, '$.ModifiedBy') AS ModifiedBy,CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2) AS DateCreated,CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) AS DateModified
		        ) AS source ON target.Pumpid = source.Pumpid 
				WHEN MATCHED THEN UPDATE SET target.Stationid = source.Stationid,target.Tankid = source.Tankid,target.Pumpname = source.Pumpname,target.Pumpmodel = source.Pumpmodel,target.Pumpnozzle = source.Pumpnozzle,target.IsDoubleSided = source.IsDoubleSided,target.ModifiedBy = source.ModifiedBy,target.DateModified = source.DateModified
				WHEN NOT MATCHED THEN INSERT (Stationid,Tankid,Pumpname,Pumpmodel,Pumpnozzle,IsDoubleSided,IsActive,IsDeleted,CreatedBy,ModifiedBy,DateCreated,DateModified)
				VALUES (source.Stationid,source.Tankid,source.Pumpname,source.Pumpmodel,source.Pumpnozzle,source.IsDoubleSided,source.IsActive,source.IsDeleted,source.CreatedBy,source.ModifiedBy,source.DateCreated,source.DateModified)
				OUTPUT inserted.PumpId INTO @Pumpdata;
				SET @Pumpid = (SELECT PumpId FROM @Pumpdata);

				-- Merge for the Pump Nozzles items
				MERGE INTO PumpNozzles AS target
				USING (SELECT JSON_VALUE(items.value, '$.Nozzleid') AS Nozzleid,JSON_VALUE(items.value, '$.Tankid') AS Tankid,JSON_VALUE(items.value, '$.Pumpid') AS Pumpid,JSON_VALUE(items.value, '$.Side') AS Side,JSON_VALUE(items.value, '$.Nozzle') AS Nozzle
				FROM OPENJSON(@JsonObjectdata, '$.StationPumpNozzles') AS items
				) AS source ON target.Nozzleid = source.Nozzleid -- Assuming ItemId is the unique identifier
				WHEN MATCHED THEN 
				UPDATE SET target.Tankid = source.Tankid,target.Pumpid = source.Pumpid,target.Nozzle=source.Nozzle
				WHEN NOT MATCHED THEN
				INSERT(Tankid,Pumpid,Side,Nozzle)
				VALUES (source.Tankid,@Pumpid,source.Side,source.Nozzle);
              END

		--IF(JSON_VALUE(@JsonObjectdata, '$.Pumpid')>0)
		--BEGIN
		--  UPDATE Stationpumps SET Tankid=JSON_VALUE(@JsonObjectdata, '$.Tankid'),Pumpname=JSON_VALUE(@JsonObjectdata, '$.Pumpname'),Pumpmodel=JSON_VALUE(@JsonObjectdata, '$.Pumpmodel'),
		--ModifiedBy=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE Pumpid=JSON_VALUE(@JsonObjectdata, '$.Pumpid')
		--END
		--ELSE
		--BEGIN
		--INSERT INTO Stationpumps(Pumpid,Stationid,Tankid,Pumpname,Pumpmodel,Pumpnozzle,IsDoubleSided,IsActive,IsDeleted,CreatedBy,ModifiedBy,DateCreated,DateModified)
	 --   (SELECT JSON_VALUE(@JsonObjectdata, '$.Stationid'),JSON_VALUE(@JsonObjectdata, '$.Tankid'),JSON_VALUE(@JsonObjectdata, '$.Pumpname'),JSON_VALUE(@JsonObjectdata, '$.Pumpmodel'),
		--JSON_VALUE(@JsonObjectdata, '$.Pumpnozzle'),JSON_VALUE(@JsonObjectdata, '$.IsDoubleSided'),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2))

		--SET @Pumpid = SCOPE_IDENTITY();
		 
		--INSERT INTO PumpNozzles(Tankid,Pumpid,Side,Nozzle)
		--SELECT Tankid,@Pumpid, Side,Nozzle
		--FROM OPENJSON (@JsonObjectdata, '$.StationPumpNozzles')
		--WITH (Tankid BIGINT,Side VARCHAR(20),Nozzle VARCHAR(50))
		--END
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
