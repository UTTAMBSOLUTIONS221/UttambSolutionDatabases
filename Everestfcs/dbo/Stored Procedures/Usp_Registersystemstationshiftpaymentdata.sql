CREATE PROCEDURE [dbo].[Usp_Registersystemstationshiftpaymentdata]
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
			    MERGE INTO ShiftPayment AS target USING (SELECT ShiftPaymentId,ShiftId,AttendantId,CustomerId,PaymentModeId,PaymentAmount,PaymentReference,IsReversed,Createdby,Modifiedby,DateCreated,DateModified
			  FROM OPENJSON(@JsonObjectdata)
			  WITH (ShiftPaymentId BIGINT '$.ShiftPaymentId',ShiftId BIGINT '$.ShiftId',AttendantId BIGINT '$.AttendantId',CustomerId BIGINT '$.CustomerId',PaymentModeId BIGINT '$.PaymentModeId',PaymentAmount DECIMAL(18, 2) '$.PaymentAmount',PaymentReference VARCHAR(100) '$.PaymentReference',IsReversed BIT '$.IsReversed',Createdby BIGINT '$.Createdby',Modifiedby BIGINT '$.Modifiedby',Datemodified DATETIME '$.DateModified',Datecreated DATETIME '$.DateCreated')
			  ) AS source ON target.ShiftPaymentId = source.ShiftPaymentId 
			  WHEN MATCHED THEN
			  UPDATE SET target.ShiftId = source.ShiftId,target.AttendantId = source.AttendantId,target.CustomerId = source.CustomerId,target.PaymentModeId = source.PaymentModeId,target.PaymentAmount = source.PaymentAmount,target.PaymentReference = source.PaymentReference,target.IsReversed = source.IsReversed,target.Modifiedby = source.Modifiedby,target.Datemodified = source.Datemodified
			  WHEN NOT MATCHED BY TARGET THEN INSERT (ShiftId,AttendantId,CustomerId,PaymentModeId,PaymentAmount,PaymentReference,IsReversed,Createdby,Modifiedby,DateCreated,DateModified) 
			  VALUES (source.ShiftId,source.AttendantId,source.CustomerId,source.PaymentModeId,source.PaymentAmount,source.PaymentReference,source.IsReversed,source.Createdby,source.Modifiedby,source.DateCreated,source.DateModified);
        
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