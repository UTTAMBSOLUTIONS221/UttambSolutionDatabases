CREATE PROCEDURE [dbo].[Usp_Getcustomeraccountequipmentproductpolicydatabyid]
	@EquipmentProductId BIGINT
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
		SELECT EquipmentProductId,EquipmentId,ProductVariationId,LimitValue,LimitPeriod,IsActive,IsDeleted,CreatedBy,ModifiedBy,DateCreated,DateModified FROM EquipmentProducts WHERE EquipmentProductId=@EquipmentProductId
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage;

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