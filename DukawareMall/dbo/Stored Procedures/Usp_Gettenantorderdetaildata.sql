CREATE PROCEDURE [dbo].[Usp_Gettenantorderdetaildata]
	@Orderownerid BIGINT
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
	    SELECT a.Orderdetailid,a.Odernumber,a.Orderownerid,b.Firstname +' '+ b.Lastname AS Fullname,a.Orderamount,a.Orderunits,CASE WHEN a.Orderstatus=2 THEN 'Recieved' WHEN  a.Orderstatus=1 THEN 'Processed' ELSE 'Completed' END AS Orderstatus,a.Isactive,a.Isdeleted,a.Extra,a.Extra1,a.Extra2,a.Extra3,a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Orderdate,a.Datecreated
		FROM Orderdetaildata a
		INNER JOIN Systemstaffs b ON a.Orderownerid=b.StaffId
		WHERE a.Orderownerid=@Orderownerid
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