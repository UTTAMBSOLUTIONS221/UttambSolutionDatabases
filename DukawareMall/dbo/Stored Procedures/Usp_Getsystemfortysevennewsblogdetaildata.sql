CREATE PROCEDURE [dbo].[Usp_Getsystemfortysevennewsblogdetaildata]
@Fortysevennewsblogdata NVARCHAR(MAX) OUTPUT
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
			SET @Fortysevennewsblogdata =(SELECT (SELECT a.Systemblogid,a.Systemblogtitle,a.Systemblogdescription,a.Systemblogcategoryid,b.BlogCategoryName,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Createdby,c.Firstname+' '+ c.lastName as Createdbyname,a.Modifiedby,d.Firstname+' '+ d.lastName as Modifiedbyname,a.Datemodified,a.Datecreated,a.Systemblogstatus,a.Isactive,a.Isdeleted,
			( 
				SELECT aa.Systemblogparagraphid,aa.Systemblogid,aa.Systemblogparagraph 
				FROM Fortysevennewsblogparagraphs aa
				WHERE a.Systemblogid=aa.Systemblogid
			    FOR JSON PATH
			) AS Blogparagraphs,
			(
				SELECT aa.Systemblogtagid,aa.Systemblogid,aa.Systemblogtag
				FROM Fortysevennewsblogtags aa
				WHERE a.Systemblogid=aa.Systemblogid
			    FOR JSON PATH
			 ) AS Blogtags,
			( 
				SELECT aa.Systemblogimageid,aa.Systemblogid,aa.Systemblogimageurl
				FROM Fortysevennewsblogimages aa
				WHERE a.Systemblogid=aa.Systemblogid
				FOR JSON PATH
			 ) AS Blogimages
			FROM Fortysevennewsblogs a
			INNER JOIN BlogCategory b ON a.Systemblogcategoryid=b.BlogCategoryId
			INNER JOIN Systemstaffs c ON a.Createdby=c.Staffid
			INNER JOIN Systemstaffs d ON a.Modifiedby=d.Staffid
			FOR JSON PATH
		) AS Fortysevennewsblogsdata
		  FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage, @Fortysevennewsblogdata AS Fortysevennewsblogdata;

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