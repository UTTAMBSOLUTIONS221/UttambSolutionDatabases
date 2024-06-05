CREATE PROCEDURE [dbo].[Usp_Getcustomercardbycardcode]
	@CardCode VARCHAR(10)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		IF EXISTS(SELECT CardId FROM Systemcard  WHERE IsActive=0 AND CardCode=@CardCode)
		Begin
			Select  1 as RespStatus, 'Card Inactive!' as RespMessage
			Return
		End
		IF EXISTS(SELECT CardId FROM Systemcard  WHERE IsDeleted=1 AND CardCode=@CardCode)
		Begin
			Select  1 as RespStatus, 'Card Deleted!' as RespMessage
			Return
		End
		IF EXISTS(SELECT CardId FROM Systemcard  WHERE IsAssigned=0 AND CardCode=@CardCode)
		Begin
			Select  1 as RespStatus, 'Card Unassigned!' as RespMessage
			Return
		End
		IF EXISTS(SELECT CardId FROM Systemcard  WHERE IsReplaced=1 AND CardCode=@CardCode)
		Begin
			Select  1 as RespStatus, 'Card Replaced!' as RespMessage
			Return
		End
		IF NOT EXISTS(SELECT CardId FROM Systemcard  WHERE CardCode=@CardCode)
		Begin
			Select  1 as RespStatus, 'Card Doesnot Exist!' as RespMessage
			Return
		End
		BEGIN TRANSACTION;
			SELECT @RespStat as RespStatus, @RespMsg as RespMessage,CardId AS Data3,TenantId AS Data4,CardUID,CardSNO,PIN AS Data1,PinHarsh AS Data2,CardCode AS Data5,IsActive,IsDeleted,IsAssigned,
			IsReplaced,TagtypeId,Createdby,Modifiedby,Datecreated,Datemodified 
			FROM Systemcard WHERE CardCode=@CardCode

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