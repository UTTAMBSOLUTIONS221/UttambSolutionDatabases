CREATE PROCEDURE [dbo].[Usp_Editsystempricelistdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate
		IF EXISTS(SELECT PriceListId FROM PriceList WHERE PriceListname=JSON_VALUE(@JsonObjectdata, '$.PriceListname'))
		Begin
		    Select  1 as RespStatus, 'Similar Name Exists' as RespMessage;
			Return
		End

		BEGIN TRANSACTION;
	       UPDATE PriceList SET PriceListname=JSON_VALUE(@JsonObjectdata, '$.PriceListname'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2) WHERE PriceListId=JSON_VALUE(@JsonObjectdata, '$.PriceListId')
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