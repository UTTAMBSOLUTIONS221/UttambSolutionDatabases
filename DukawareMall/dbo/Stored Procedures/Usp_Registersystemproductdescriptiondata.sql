CREATE PROCEDURE dbo.Usp_Registersystemproductdescriptiondata
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
		IF(JSON_VALUE(@JsonObjectdata, '$.DescriptionId')=0)
		BEGIN
		INSERT INTO Systemproductdescription(SystemproductId,Descriptiondata,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
		(SELECT JSON_VALUE(@JsonObjectdata, '$.SystemproductId'),JSON_VALUE(@JsonObjectdata, '$.Descriptiondata'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),
		JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		Set @RespMsg ='Product Description Saved Successfully.'
		Set @RespStat =0; 
		END
		ELSE
		BEGIN
		
		UPDATE Systemproductdescription SET Descriptiondata=JSON_VALUE(@JsonObjectdata, '$.Descriptiondata'),
		Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE DescriptionId =JSON_VALUE(@JsonObjectdata, '$.DescriptionId')

		Set @RespMsg ='Product Description Updated Successfully.'
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