CREATE PROCEDURE [dbo].[Usp_Getsystemassetdatabyid]
	@Assetid BIGINT
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
			SELECT a.Assetid,a.Assetname,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,a.Isactive,a.Isdeleted,a.Createdby,a.Modifiedby,a.Datemodified,a.Datecreated FROM Systemassets a WHERE a.Assetid=@Assetid
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