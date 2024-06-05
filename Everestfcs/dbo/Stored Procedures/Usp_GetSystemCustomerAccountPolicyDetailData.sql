CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAccountPolicyDetailData]
	@AccountId BIGINT,
	@CustomerAccountPolicyDetailsJson NVARCHAR(MAX) OUTPUT
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
		SET @CustomerAccountPolicyDetailsJson =(
		SELECT 
			a.AccountId,a.AccountNumber,
			c.CardSNO AS MaskNumber, 
			(
			SELECT a.AccountProductId,a.AccountId,a.ProductVariationId,b.Productvariationname,a.LimitValue,a.LimitPeriod,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM AccountProducts a
			INNER JOIN SystemProductvariation b ON a.ProductVariationId=b.ProductvariationId
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.AccountId=a.AccountId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS Accountproductspolicy,
			(
			SELECT a.AccountStationId,a.AccountId,a.StationId,b.Sname AS Stationname,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM AccountStations a
			INNER JOIN SystemStations b ON a.StationId=b.StationId
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.AccountId=a.AccountId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS Accountstationspolicy,
			(SELECT a.AccountWeekDaysId,a.AccountId,a.WeekDays,a.StartTime,a.EndTime,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM AccountWeekDays a
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.AccountId=a.AccountId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS Accountweekdayspolicy,
			(SELECT a.AccountFrequencyId,a.AccountId,a.Frequency,a.FrequencyPeriod,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM AccountTransactionFrequency a
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.AccountId=a.AccountId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS Accountfrequencypolicy
			FROM CustomerAccount a
			INNER JOIN SystemAccountCards b ON a.AccountId=b.AccountId
			INNER JOIN Systemcard c ON b.CardId=c.CardId

		WHERE a.AccountId =@AccountId
        FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerAccountPolicyDetailsJson as CustomerAccountPolicyDetailsJson;

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