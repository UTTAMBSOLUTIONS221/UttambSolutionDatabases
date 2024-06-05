CREATE PROCEDURE [dbo].[Usp_Registersystemstationshifttopupdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
			  MERGE INTO ShiftTopup AS target USING (SELECT ShiftTopupId,ShiftId,AttendantId,TopupAmount,TopupReference,IsReversed,Createdby,Modifiedby,DateCreated,DateModified
			  FROM OPENJSON(@JsonObjectdata)
			  WITH (ShiftTopupId BIGINT '$.ShiftTopupId',ShiftId BIGINT '$.ShiftId',AttendantId BIGINT '$.AttendantId',TopupAmount DECIMAL(18, 2) '$.TopupAmount',TopupReference VARCHAR(100) '$.TopupReference',IsReversed BIT '$.IsReversed',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',Datemodified DATETIME '$.DateModified',Datecreated DATETIME '$.DateCreated')
			  ) AS source ON target.ShiftTopupId = source.ShiftTopupId 
			  WHEN MATCHED THEN
			  UPDATE SET target.ShiftId = source.ShiftId,target.AttendantId = source.AttendantId,target.TopupAmount = source.TopupAmount,target.TopupReference = source.TopupReference,target.IsReversed = source.IsReversed,target.Modifiedby = source.Modifiedby,target.Datemodified = source.Datemodified
			  WHEN NOT MATCHED BY TARGET THEN INSERT (ShiftId,AttendantId,TopupAmount,TopupReference,IsReversed,Createdby,Modifiedby,DateCreated,DateModified) 
			  VALUES (source.ShiftId,source.AttendantId,source.TopupAmount,source.TopupReference,source.IsReversed,source.Createdby,source.Modifiedby,source.DateCreated,source.DateModified);
        
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