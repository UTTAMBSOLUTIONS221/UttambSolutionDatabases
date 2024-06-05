CREATE PROCEDURE [dbo].[Usp_Registersystemblogdata]
@JsonObjectdata VARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Systemblogid BIGINT;
		  
	BEGIN
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		INSERT INTO Fortysevennewsblogs(Systemblogtitle,Systemblogdescription,Systemblogcategoryid,Createdby,Modifiedby,Datemodified,Datecreated)
	    (SELECT JSON_VALUE(@JsonObjectdata, '$.Systemblogtitle'),JSON_VALUE(@JsonObjectdata, '$.Systemblogdescription'),JSON_VALUE(@JsonObjectdata, '$.Systemblogcategoryid'),
		JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),
		CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated')  AS datetime2))

		SET @Systemblogid = SCOPE_IDENTITY();
		 
		INSERT INTO Fortysevennewsblogparagraphs(Systemblogid,Systemblogparagraph)
		SELECT @Systemblogid, Systemblogparagraph FROM OPENJSON (@JsonObjectdata, '$.Blogparagraphs') WITH (Systemblogparagraph VARCHAR(8000))

		INSERT INTO Fortysevennewsblogtags(Systemblogid,Systemblogtag)
		SELECT @Systemblogid, Systemblogtag FROM OPENJSON (@JsonObjectdata, '$.Blogtags') WITH (Systemblogtag VARCHAR(400))

		INSERT INTO Fortysevennewsblogimages(Systemblogid,Systemblogimageurl)
		SELECT @Systemblogid, Systemblogimageurl FROM OPENJSON (@JsonObjectdata, '$.Blogimages') WITH (Systemblogimageurl VARCHAR(400))

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