CREATE PROCEDURE [dbo].[Usp_RegisterSystemGadgetsData]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.GadgetId')=0)
		BEGIN
			INSERT INTO SystemGadgets(Tenantid,GadgetName,Descriptions,Imei1,Imei12,Serialnumber,IsActive,IsDeleted,Createdby,Modifiedby,DateCreated,DateModified)
			(SELECT JSON_VALUE(@JsonObjectdata, '$.TenantId'),JSON_VALUE(@JsonObjectdata, '$.GadgetName'),JSON_VALUE(@JsonObjectdata, '$.Descriptions'),
			JSON_VALUE(@JsonObjectdata, '$.Imei1'),JSON_VALUE(@JsonObjectdata, '$.Imei12'),JSON_VALUE(@JsonObjectdata, '$.Serialnumber'),1,0,
			JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),
			CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2))
		    
			INSERT INTO LnkGadgetsStation(GadgetId,StationId)
			SELECT SCOPE_IDENTITY(),JSON_VALUE(@JsonObjectdata, '$.StationId')
		
		END
		ELSE
		BEGIN

		 UPDATE SystemGadgets SET GadgetName=JSON_VALUE(@JsonObjectdata, '$.GadgetName'),Descriptions=JSON_VALUE(@JsonObjectdata, '$.Descriptions'),
			Imei1=JSON_VALUE(@JsonObjectdata, '$.Imei1'),Imei12=JSON_VALUE(@JsonObjectdata, '$.Imei12'),Serialnumber=JSON_VALUE(@JsonObjectdata, '$.Serialnumber'),
			Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified') AS datetime2) WHERE GadgetId=JSON_VALUE(@JsonObjectdata, '$.GadgetId')
		

		 UPDATE LnkGadgetsStation SET StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') WHERE GadgetId=JSON_VALUE(@JsonObjectdata, '$.GadgetId')
		
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