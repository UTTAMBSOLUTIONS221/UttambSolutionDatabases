CREATE PROCEDURE [dbo].[Usp_Getsystemcustomerdetaildatabyassetnumber]
@Assetnumber VARCHAR(100)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		IF NOT EXISTS(SELECT a.Assetdetailid FROM Systemassetdetail a WHERE a.Assetnumber=@Assetnumber)
		Begin
			Select  1 as RespStatus, 'Invalid!, Account does not Exist!' as RespMessage;
			Return
		End
		BEGIN TRANSACTION;
			SELECT @RespStat as RespStatus, @RespMsg as RespMessage,c.AccountNumber AS Data1,a.AssetNumber AS Data2,d.Codename+ ''+ b.Phonenumber AS Data3,b.Firstname +' '+ b.Lastname AS Data4, f.Vehiclemakename +' '+ g.Vehiclemodelname AS Dat4 
			FROM Systemassetdetail a 
			INNER JOIN Systemcustomers b ON a.CustomerId=b.CustomerId
			INNER JOIN Customeraccount c ON b.CustomerId=c.CustomerId
			INNER JOIN SystemPhonecodes d ON b.phoneid=d.phoneid
			INNER JOIN Systemassetdetail e ON  a.Assetdetailid=e.Assetdetailid
			INNER JOIN Systemvehiclemakes f ON e.Assetmakeid=f.Vehiclemakeid
			INNER JOIN Systemvehiclemodels g ON e.Assetmodelid=g.Vehiclemodelid
		    WHERE a.Assetnumber=@Assetnumber
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