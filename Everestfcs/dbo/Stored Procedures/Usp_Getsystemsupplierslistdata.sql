CREATE PROCEDURE [dbo].[Usp_Getsystemsupplierslistdata]
	@TenantId BIGINT
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
		SELECT  a.SupplierId,a.TenantId,a.SupplierName,a.SupplierEmail,c.Codename+''+a.Phonenumber AS Phonenumber,a.Extra,a.Extra1,a.Extra2,a.Extra3,
		a.Extra4,a.Extra5,a.Extra6,a.Extra7,a.Extra8,a.Extra9,a.Extra10,b.Firstname+' '+b.Lastname AS Createdby,d.Firstname+' '+d.Lastname AS Modifiedby,a.Datemodified,a.Datecreated
		FROM SystemSuppliers a
		INNER JOIN SystemPhoneCodes c ON a.PhoneId=c.PhoneId 
		INNER JOIN SystemStaffs b ON a.Createdby=b.Userid
		INNER JOIN SystemStaffs d ON a.Modifiedby=d.Userid
		 WHERE a.TenantId=@TenantId
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage;

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