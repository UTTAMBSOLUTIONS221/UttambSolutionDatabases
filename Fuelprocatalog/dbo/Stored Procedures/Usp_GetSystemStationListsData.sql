CREATE PROCEDURE [dbo].[Usp_GetSystemStationListsData]
    @Tenantid BIGINT,
	@Offset INT,
	@Count INT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		If(@Count=0)
		BEGIN
		 SET @Count=10;
		END
		BEGIN TRANSACTION;
		SELECT StationId,Tenantid,Sname,Semail,Phone,Addresses,City,Street,IsDefault,IsActive,IsDeleted,CreatedBy,DateCreated FROM SystemStations a WHERE a.Tenantid= @Tenantid
		ORDER BY a.Datecreated 
		OFFSET @Offset ROWS
		FETCH NEXT @Count ROWS ONLY;

	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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