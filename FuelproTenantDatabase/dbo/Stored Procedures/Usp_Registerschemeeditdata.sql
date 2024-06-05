CREATE PROCEDURE [dbo].[Usp_Registerschemeeditdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '';
		  
	BEGIN
		BEGIN TRY	
		--Validate
		IF EXISTS(SELECT LSchemeId FROM LSchemes WHERE LSchemeName=JSON_VALUE(@JsonObjectdata, '$.LSchemeName'))
		Begin
		    Select  1 as RespStatus, 'Similar Name Exists' as RespMessage;
			Return
		End

		BEGIN TRANSACTION;
		 UPDATE LSchemes SET LSchemeName=JSON_VALUE(@JsonObjectdata, '$.LSchemeName'),StartDate=CAST(JSON_VALUE(@JsonObjectdata, '$.StartDate')  AS datetime2),EndDate=CAST(JSON_VALUE(@JsonObjectdata, '$.EndDate')  AS datetime2),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE LSchemeId=JSON_VALUE(@JsonObjectdata, '$.LSchemeId')
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