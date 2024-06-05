CREATE PROCEDURE [dbo].[Usp_GetSystemBlogCategorydata]
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		
		BEGIN TRANSACTION;
		  SELECT a.BlogCategoryId,a.BlogCategoryName,a.CreatedBy,a.ModifiedBy,
		   b.Firstname +' '+ b.Lastname  AS Createdbyname,a.ModifiedBy, c.Firstname +' '+ c.Lastname AS Modifiedbyname,a.DateCreated,a.DateModified
		  FROM BlogCategory a
		  INNER JOIN Systemstaffs b ON a.Createdby =b.Staffid
		  INNER JOIN Systemstaffs c ON a.Modifiedby =c.Staffid
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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