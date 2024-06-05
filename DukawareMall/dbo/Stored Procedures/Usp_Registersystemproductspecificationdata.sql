CREATE PROCEDURE [dbo].[Usp_Registersystemproductspecificationdata]
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
		IF(JSON_VALUE(@JsonObjectdata, '$.SpecificationId')=0)
		BEGIN
		INSERT INTO Systemproductspecification(SystemproductId,Specificationdata,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.SystemproductId'),JSON_VALUE(@JsonObjectdata, '$.Specificationdata'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),
		JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		Set @RespMsg ='Product Specifications Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Systemproductspecification SET Specificationdata=JSON_VALUE(@JsonObjectdata, '$.Specificationdata'),
		Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE SpecificationId =JSON_VALUE(@JsonObjectdata, '$.SpecificationId')

		Set @RespMsg ='Product Specifications Updated Successfully.'
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