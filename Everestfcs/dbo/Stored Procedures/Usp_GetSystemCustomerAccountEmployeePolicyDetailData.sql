CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAccountEmployeePolicyDetailData]
	@EmployeeId BIGINT,
	@CustomerAccountEmployeePolicyDetailsJson NVARCHAR(MAX) OUTPUT
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
		SET @CustomerAccountEmployeePolicyDetailsJson =(
		SELECT 
			a.EmployeeId,a.Firstname+' '+ a.Lastname AS EmployeeName, 
			(
			SELECT a.EmployeeProductId,a.EmployeeId,a.ProductVariationId,b.Productvariationname,a.LimitValue,a.LimitPeriod,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EmployeeProducts a
			INNER JOIN SystemProductvariation b ON a.ProductVariationId=b.ProductvariationId
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EmployeeId=a.EmployeeId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEmployeeproductspolicy,
			(
			SELECT a.EmployeeStationId,a.EmployeeId,a.StationId,b.Sname AS Stationname,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EmployeeStations a
			INNER JOIN SystemStations b ON a.StationId=b.StationId
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EmployeeId=a.EmployeeId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEmployeestationspolicy,
			(SELECT a.EmployeeWeekDaysId,a.EmployeeId,a.WeekDays,a.StartTime,a.EndTime,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EmployeeWeekDays a
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EmployeeId=a.EmployeeId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEmployeeweekdayspolicy,
			(SELECT a.EmployeeFrequencyId,a.EmployeeId,a.Frequency,a.FrequencyPeriod,
				   a.IsActive,a.IsDeleted,c.Firstname+' '+c.Lastname AS  CreatedBy,d.Firstname+' '+d.Lastname AS ModifiedBy,a.DateCreated,a.DateModified
			FROM EmployeeTransactionFrequency a
			LEFT JOIN SystemStaffs c ON a.CreatedBy =c.UserId
			LEFT JOIN SystemStaffs d ON a.ModifiedBy =d.UserId
			WHERE a.EmployeeId=a.EmployeeId
			FOR JSON PATH ,INCLUDE_NULL_VALUES 
			) AS AccountEmployeefrequencypolicy
			FROM CustomerEmployees a
		WHERE a.EmployeeId =@EmployeeId
        FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerAccountEmployeePolicyDetailsJson as CustomerAccountEmployeePolicyDetailsJson;

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