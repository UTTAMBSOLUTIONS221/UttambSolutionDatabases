CREATE PROCEDURE [dbo].[Usp_RegisterSystemTenantCardsData]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.CardId')=0)
		BEGIN
		INSERT INTO Systemcard(CardUID,CardSNO,PIN,PinHarsh,IsActive,IsDeleted,IsAssigned,IsReplaced,TagtypeId,Createdby,Modifiedby,Datecreated,Datemodified)
	    SELECT JSON_VALUE(@JsonObjectdata, '$.CardUID'),JSON_VALUE(@JsonObjectdata, '$.CardSNO'),JSON_VALUE(@JsonObjectdata, '$.PIN'),JSON_VALUE(@JsonObjectdata, '$.PinHarsh'),1,0,JSON_VALUE(@JsonObjectdata, '$.IsAssigned'),0,JSON_VALUE(@JsonObjectdata, '$.TagtypeId'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)

		Set @RespMsg ='Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		UPDATE Systemcard SET CardUID=JSON_VALUE(@JsonObjectdata, '$.CardUID'),CardSNO=JSON_VALUE(@JsonObjectdata, '$.CardSNO'),TagtypeId=JSON_VALUE(@JsonObjectdata, '$.TagtypeId'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE CardId=JSON_VALUE(@JsonObjectdata, '$.CardId')
		Set @RespMsg ='Updated Successfully.'
		Set @RespStat =0; 
		END
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