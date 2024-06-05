CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountEquipmentStationPolicyData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
			BEGIN
	
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		   DELETE FROM EquipmentStations WHERE EquipmentId = JSON_VALUE(@JsonObjectdata, '$.EquipmentId') AND StationId NOT IN (SELECT StationId FROM OPENJSON(JSON_VALUE(@JsonObjectdata, '$.StationId')) WITH (StationId INT '$.StationId'));

			INSERT INTO EquipmentStations (EquipmentId, StationId, IsActive, IsDeleted, CreatedBy, ModifiedBy, DateCreated, DateModified)
			SELECT JSON_VALUE(@JsonObjectdata, '$.EquipmentId'),value AS StationId,1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
			FROM OPENJSON(@JsonObjectdata, '$.StationId') WHERE NOT EXISTS (SELECT 1 FROM EquipmentStations WHERE EquipmentId = JSON_VALUE(@JsonObjectdata, '$.EquipmentId'));
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,JSON_VALUE(@JsonObjectdata, '$.EquipmentId') AS Data1, JSON_VALUE(@JsonObjectdata, '$.EquipmentNumber') AS Data2;

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
