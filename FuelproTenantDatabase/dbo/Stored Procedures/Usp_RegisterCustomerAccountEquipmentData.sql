CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAccountEquipmentData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@EquipmentId BIGINT;
			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.EquipmentId')=0)
		BEGIN
			IF EXISTS(SELECT EquipmentId FROM CustomerEquipments WHERE EquipmentRegNo=JSON_VALUE(@JsonObjectdata, '$.EquipmentReg'))
			BEGIN
				Select  1 as RespStatus, 'Similar Registration exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.EquipmentId')>0)
		BEGIN
		     UPDATE CustomerEquipments SET ProductVariationId=JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),EquipmentMakeId=JSON_VALUE(@JsonObjectdata, '$.VehicleMakeId'),EquipmentModelId=JSON_VALUE(@JsonObjectdata, '$.VehicleModelId'),EquipmentRegNo=JSON_VALUE(@JsonObjectdata, '$.EquipmentReg'),TankCapacity=JSON_VALUE(@JsonObjectdata, '$.TankCapacity'),Odometer=JSON_VALUE(@JsonObjectdata, '$.OdometerReading'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2) WHERE EquipmentId=JSON_VALUE(@JsonObjectdata, '$.EquipmentId')
		END
		ELSE
		BEGIN
			INSERT INTO CustomerEquipments(ProductVariationId,EquipmentMakeId,EquipmentModelId,EquipmentRegNo,TankCapacity,Odometer,IsActive,IsDeleted,Createdby,Modifiedby,DateCreated,DateModified)
			SELECT JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),JSON_VALUE(@JsonObjectdata, '$.VehicleMakeId'),JSON_VALUE(@JsonObjectdata, '$.VehicleModelId'),JSON_VALUE(@JsonObjectdata, '$.EquipmentReg'),JSON_VALUE(@JsonObjectdata, '$.TankCapacity'),
			JSON_VALUE(@JsonObjectdata, '$.OdometerReading'),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
			CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)

		   SET @EquipmentId=SCOPE_IDENTITY();


			INSERT INTO AccountEquipments(AccountId,EquipmentId)
			VALUES(JSON_VALUE(@JsonObjectdata, '$.AccountId'),@EquipmentId)
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