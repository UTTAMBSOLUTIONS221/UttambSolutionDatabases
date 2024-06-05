
CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAccountEquipmentPolicyDetailData]
	@EquipmentId BIGINT,
	@CustomerAccountEquipmentPolicyDetailsJson NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	

		
		BEGIN TRANSACTION;
		SET @CustomerAccountEquipmentPolicyDetailsJson =(
		SELECT 
			a.EquipmentId,a.EquipmentRegNo AS EquipmentNumber, 
			(
			SELECT a.EquipmentProductId,a.EquipmentId,a.ProductVariationId,b.Productvariationname,a.LimitValue,a.LimitPeriod,
				   a.IsActive,a.IsDeleted,c.Fullname AS  CreatedBy,d.Fullname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EquipmentProducts a
			INNER JOIN SystemProductvariation b ON a.ProductVariationId=b.ProductvariationId
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EquipmentId=a.EquipmentId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEquipmentproductspolicy,
			(
			SELECT a.EquipmentStationId,a.EquipmentId,a.StationId,b.Sname AS Stationname,
				   a.IsActive,a.IsDeleted,c.Fullname AS  CreatedBy,d.Fullname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EquipmentStations a
			INNER JOIN SystemStations b ON a.StationId=b.Tenantstationid
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EquipmentId=a.EquipmentId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEquipmentstationspolicy,
			(SELECT a.EquipmentWeekDaysId,a.EquipmentId,a.WeekDays,a.StartTime,a.EndTime,
				   a.IsActive,a.IsDeleted,c.Fullname AS  CreatedBy,d.Fullname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EquipmentWeekDays a
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EquipmentId=a.EquipmentId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEquipmentweekdayspolicy,
			(SELECT a.EquipmentFrequencyId,a.EquipmentId,a.Frequency,a.FrequencyPeriod,
				   a.IsActive,a.IsDeleted,c.Fullname AS  CreatedBy,d.Fullname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EquipmentTransactionFrequency a
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EquipmentId=a.EquipmentId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEquipmentfrequencypolicy
			FROM CustomerEquipments a


		WHERE a.EquipmentId =@EquipmentId
        FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerAccountEquipmentPolicyDetailsJson as CustomerAccountEquipmentPolicyDetailsJson;

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