CREATE PROCEDURE [dbo].[Usp_Registertenantproductstockdata]
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
		BEGIN
			IF(JSON_VALUE(@JsonObjectdata, '$.Stockaction')='Stock')
			BEGIN
			 UPDATE Tenantproduct SET Productunits=Productunits + JSON_VALUE(@JsonObjectdata, '$.Stockunits') WHERE TenantproductId =JSON_VALUE(@JsonObjectdata, '$.TenantproductId')
			END
			ELSE
			BEGIN
			 UPDATE Tenantproduct SET Productunits=Productunits - JSON_VALUE(@JsonObjectdata, '$.Stockunits') WHERE TenantproductId =JSON_VALUE(@JsonObjectdata, '$.TenantproductId')
			END
			 INSERT INTO Tenantproductstock(TenantproductId,Actionname,Productunits,Createdby,Datecreated)
			(SELECT JSON_VALUE(@JsonObjectdata, '$.TenantproductId'),JSON_VALUE(@JsonObjectdata, '$.Stockaction'),JSON_VALUE(@JsonObjectdata, '$.Stockunits'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

			Set @RespMsg ='Product Stock Adjusted Successfully.'
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