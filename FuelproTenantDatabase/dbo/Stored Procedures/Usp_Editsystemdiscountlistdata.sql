CREATE PROCEDURE [dbo].[Usp_Editsystemdiscountlistdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate
		IF EXISTS(SELECT DiscountListId FROM DiscountList WHERE DiscountListname=JSON_VALUE(@JsonObjectdata, '$.DiscountListname'))
		Begin
		    Select  1 as RespStatus, 'Similar Name Exists' as RespMessage;
			Return
		End

		BEGIN TRANSACTION;
	       UPDATE DiscountList SET DiscountListname=JSON_VALUE(@JsonObjectdata, '$.DiscountListname'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2) WHERE DiscountListId=JSON_VALUE(@JsonObjectdata, '$.DiscountListId')
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